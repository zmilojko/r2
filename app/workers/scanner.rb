require 'rest_client'

STDOUT.sync = true

class Scanner
  include Sidekiq::Worker
  sidekiq_options queue: SidekiqCtrl.defaultQueue
  
  def log s
    if @site
      @my_logger ||= Logger.new Rails.root.join("log", "#{@site.real_code_file_name}_scan.log")
      @my_logger.info s.to_s
    end
  end
  
  def full_url(url)
    if /https?\:\/\/#{@site.name}/.match url
      # this is a full url
      url
    else 
      "http#{'s' if @site.use_ssl}://#{@site.name}#{url[0] == "/" ? "" : "/"}#{url}"
    end
  end
  
  def get_page url
    # log "  => wanting to get #{url}, full: #{full_url(url)}"
    response = RestClient.get full_url(url),
        user_agent: "re-bot",
        cookies: @site.scanner_buffer.cookies
    @site.scanner_buffer.cookies = response.cookies unless response.cookies.blank?
    response
  end
  
  def convert_to_utf page
    encoding = ""
    page = page.to_s
    begin
      doc = Nokogiri::HTML(page)
      doc.xpath('//meta').each do |meta_tag|
        begin
          # <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1"/>
          content_attr = meta_tag.attributes['content'].value
          encoding = content_attr[/charset=([\w\-]+)/,1]
          break unless encoding.blank?
        rescue
        end
        begin
          # <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1"/>
          encoding = meta_tag.attributes['charset'].value
          break unless encoding.blank?
        rescue
        end
      end
    rescue
      log "Unessuccessfully searching following for conversion: #{page[0,1000]}"
    end
    
    encoding = @site.encoding if encoding.blank?
    encoding = @site.scanner_buffer.some_previously_used_encoding if encoding.blank?
    
    if (not encoding.blank?) and encoding.downcase == "utf-8"
      log "  => Content is UTF-8"
      @site.scanner_buffer.no_encoding_counter = 5
      return page
    end
    
    unless encoding.blank?
      # now we have the best guess for encoding, but that still be illegal
      # first try to get or create the Converter, if that works, we believe
      # encoding info is ok
      begin
        @site.scanner_buffer.converters[encoding] ||= Encoding::Converter.new(encoding,"UTF-8")
      rescue
        encoding = nil
      end
    end
    unless encoding.blank?
      # if nobody set encoding to nil, we have the converter!
      @site.scanner_buffer.no_encoding_counter = 5
      @site.scanner_buffer.some_previously_used_encoding ||= encoding
      page = @site.scanner_buffer.converters[encoding].convert page
      log "  => Content converted from #{encoding} to utf-8"
    else
      if @site.scanner_buffer.no_encoding_counter > 0
        @site.scanner_buffer.no_encoding_counter -= 1
        log "  \033[35m=> Cannot figure out encoding!\033[0m"
      else
        if @site.scanner_buffer.no_encoding_counter == 0
          @site.scanner_buffer.no_encoding_counter -= 1
           log "  \033[35m=> Cannot figure out encoding!\033[0m"
          log "  \033[35m=> It seems encoding is not specified accross the site!\033[0m"
          log "  \033[35m=> Scanner will no longer be reporting this message.\033[0m"
        end
      end
    end
    page
  end

  def should_process_page url, referral
    #for now, check that it is on our site
    if /^http/.match url
      unless /^https?\:\/\/#{@site.name}/.match url
        return false
      end
    elsif /^mailto\:/.match url
      return false
    elsif /^javascript\:/.match url
      return false
    end
    
    if @site.harvester.class == Harvester
      
      return true # there is no harvester - get the whole site
    end
    result = @site.harvester.filter_url url, filter_for: :crowling, referral: referral, site: @site
    return false if result.blank?

    result
  end
  
  def process_url(scan)
    # flush now to increase possibility that multiple threads log it together
    # later we will make separate log files
    # STDOUT.flush
    log "=> fetching #{scan.full_url}"
    
    begin
      page = get_page scan.full_url
    rescue
      log "  => error fetching!"
      response = @site.harvester.do_handle_scanning_error $!
      @site.reset_cookie
      response.each do |action, action_parameters|
        case action
        when :log
          log "  \033[35m=> #{action_parameters || "Error scanning page"} #{scan.full_url}\033[0m"
        when :log_error
          log "  \033[35m=> #{$!}\033[0m"
        when :pause
          raise "Error occured, try again soon."
        when :ignore, :do_not_try_again
          scan.scanning_error = convert_to_utf($!)
          scan.last_visited = Time.now
          scan.save!
        end
      end
      return
    end
    log "  => received, processing"
    page = convert_to_utf page
    scan.last_visited = nil
    scan.content = page
    scan.save!
    
    doc = Nokogiri::HTML(page)
    all_links = doc.search('a')
    
    count = 0
    actual = 0
    # log "  => analyzing step 1"
    potential_urls = all_links.map do |link| 
      begin
        l = link.attributes['href'].value
        l.blank? ? nil : l
      rescue
        nil
      end
    end.compact
    
    # log "  => analyzing step 2"
    
    filtered_urls = potential_urls.map do |link|
      result = should_process_page((new_url = link), scan.full_url)
      unless result.blank?
        if result.is_a? Hash and result[:replace_url]
          new_url = result[:replace_url]
        end
        new_url        
      else
        nil
      end
    end.compact
    # log "  => analyzing step 3"
    moped_error_level = Moped.logger.level
    Moped.logger.level = Logger::ERROR
    Mongoid.logger.level = Logger::ERROR
    existing_urls = @site.scans.where(:url.in => filtered_urls).batch_size(4000).all.map { |z| z.url }
    # Moped.logger.level = moped_error_level
    # log "  => analyzing step 4"
    new_counter = 0
    filtered_urls.each do |x|
      unless existing_urls.any? {|y| y == Scan.url_token(x) }
        # log "    => creating url"
        @site.scans.create url: Scan.url_token(x),
          last_visited: nil,
          referral: scan.url,
          actual_url: ((Scan.url_token(x) != x) ? x : nil)
        new_counter += 1
      end
    end
    # log "  => analyzing step 5"
    log "  => analyzed #{potential_urls.count}/#{filtered_urls.count}/#{new_counter} new urls for later"

=begin
    all_links.each do |link|
      begin
        new_url = link.attributes['href'].value
      rescue
        next
      end
      # or now, search all links on the site
      # log "    => found link to #{new_url}"
      result = should_process_page(new_url, scan.full_url)
      unless result.blank?
        if result.is_a? Hash and result[:replace_url]
          new_url = result[:replace_url]
        end
        # log "    => should be added, if already there #{new_url}"
        count += 1
        s1 = @site.scans.find_or_create_by url: Scan.url_token(new_url) do |s|
          s.last_visited = nil
          s.referral = scan.url
          if Scan.url_token(new_url) != new_url
            # this bizare condition is here because token is different
            # from URL when URL is too long, and then we do want to remember the original  one
            puts "    \033[35m=> #HANDLING LONG URL\033[0m"
            log "    \033[35m=> #HANDLING LONG URL\033[0m"
            s.actual_url = new_url
          end
          actual += 1
          # log "    => added #{new_url}"
        end
      end
    end
=end
    
    scan.last_visited = Time.now
    scan.save!
    #log "  => queued #{all_links.count}/#{count}/#{actual} new urls for later"
  end
  
  def perform(host, ticket_no)
    log "  => Starting..." 
    
    @site = Site.find_by(name: host)
    @harvester = @site.harvester
  
    loop do
      @site.reload
      
      if @site.ticket_no != ticket_no
        log "Somebody changed the ticket, this job is quitting"
        break
      end

      if @site.mode_sym == :off
        @site.status = :off
        @site.save!
        break
      end
      
      if @site.should_sleep
        if @site.status_sym != :asleep
          log "scanner for #{@site.name} going to sleep"
          @site.status = :asleep
          @site.save!
        end
        sleep 5
        next
      end
      
      @site.status = :on
      @site.save!
  
      #log "  => Looking for new scan to attack..." 
      
      # next_scan = Scan.find_by site_id: @site.id, last_visited: nil
      next_scan = @site.scans.where(last_visited: nil).order_by(:created_at => 'desc').first
      
      #log "  => Found next..." if next_scan
      
      if next_scan.nil?
        log "Completed scanning"
        @site.status = :off
        @site.mode = :off
        @site.save!
        break;
      end

      process_url next_scan
      
      # Instead of looping, scehedule next here!
      @site.start_scanner # delay: 0
      # log "  => Scheduling next..." 
      return
    end
    @site.status = :off
    @site.mode = :off
    @site.save!
    log "Completed scanning task for #{@site.name}"
  end
end