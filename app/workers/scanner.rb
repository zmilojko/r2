require 'rest_client'

class Scanner
  include Sidekiq::Worker
  sidekiq_options :queue => SidekiqCtrl.defaultQueue
  
  def initialize
    @cookies = nil
    @converters = {}
    @some_previously_used_encoding = nil
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
    # puts "  => wanting to get #{url}, full: #{full_url(url)}"
    response = RestClient.get full_url(url),
        user_agent: "re-bot",
        cookies: @cookies
    @cookies = response.cookies unless response.cookies.blank?
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
      puts "Unessuccessfully searching following for conversion: #{page[0,1000]}"
    end
    
    encoding = @site.encoding if encoding.blank?
    encoding = @some_previously_used_encoding if encoding.blank?
    
    if (not encoding.blank?) and encoding.downcase == "utf-8"
      puts "  => Content is UTF-8"
      return page
    end
    
    unless encoding.blank?
      # now we have the best guess for encoding, but that still be illegal
      # first try to get or create the Converter, if that works, we believe
      # encoding info is ok
      begin
        @converters[encoding] ||= Encoding::Converter.new(encoding,"UTF-8")
      rescue
        encoding = nil
      end
    end
    unless encoding.blank?
      # if nobody set encoding to nil, we have the converter!
      @some_previously_used_encoding ||= encoding
      page = @converters[encoding].convert page
      puts "  => Content converted from #{encoding} to utf-8"
    else
      puts "  \033[35m=> Cannot figure out encoding!\033[0m"
    end
    page
  end

  def should_process_page url
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
    filter url
  end
  
  def process_url(scan)
    # flush now to increase possibility that multiple threads log it together
    # later we will make separate log files
    STDOUT.flush
    puts "=> processing #{scan.url}"
    
    begin
      page = get_page scan.url
    rescue
      puts "  \033[35m=> Cannot find page #{scan.url}\033[0m"
      scan.scanning_error = convert_to_utf($!)
      scan.last_visited = Time.now
      scan.save!
      return
    end
    page = convert_to_utf page
    scan.last_visited = nil
    scan.content = page
    scan.save!
    
    doc = Nokogiri::HTML(page)
    all_links = doc.search('a')
    
    count = 0
    actual = 0
    
    all_links.each do |link|
      begin
        new_url = link.attributes['href'].value
      rescue
        next
      end
      # or now, search all links on the site
      # puts "    => found link to #{new_url}"
      if should_process_page new_url
        # puts "    => should be added, if already there #{new_url}"
        count += 1
        s1 = @site.scans.find_or_create_by url: new_url do |s|
          s.last_visited = nil
          s.referral = scan.url
          actual += 1
          # puts "    => added #{new_url}"
        end
      end
    end
    
    scan.last_visited = Time.now
    scan.save!
    puts "  => queued #{all_links.count}/#{count}/#{actual} new urls for later"
  end
  
  def filter url
    if @site.harvester.class == Harvester
      true # there is no harvester - get the whole site
    else
      @site.harvester.filter_url url, filter_for: :crowling
    end
  end
      
  
  def perform(host, ticket_no)
    @site = Site.find_by(name: host)
    @harvester = @site.harvester
    loop do
      @site.reload
      
      if @site.ticket_no != ticket_no
        puts "Somebody changed the ticket, this job is quitting"
        break
      end

      if @site.mode_sym == :off
        @site.status = :off
        @site.save!
        break
      end
      
      if @site.should_sleep
        if @site.status_sym != :asleep
          puts "scanner for #{@site.name} going to sleep"
          @site.status = :asleep
          @site.save!
        end
        sleep 5
        next
      end
      
      @site.status = :on
      @site.save!
      
      next_scan = @site.scans.find_by(last_visited: nil)
      
      if next_scan.nil?
        puts "Completed scanning"
        @site.status = :off
        @site.mode = :off
        @site.save!
        break;
      end

      process_url next_scan
    end
    @site.status = :off
    @site.mode = :off
    @site.save!
    puts "Completed scanning task for #{@site.name}"
  end
end