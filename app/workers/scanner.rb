require 'rest_client'
STDOUT.sync = true

class Scanner
  include Sidekiq::Worker
  
  def initialize
    @cookies = nil
    @converters = nil
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
    doc = Nokogiri::HTML(page)
    encoding = nil
    doc.xpath('//meta').each do |meta_tag|
      begin
        content_attr = meta_tag.attributes['content'].value
        encoding = content_attr[/charset=([\w\-]+)/,1]
      rescue
      end
    end
    
    encoding ||= @site.encoding
    encoding ||= @some_previously_used_encoding
    
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
    end
    page
  end

  def should_process_page url
    #for now, check that it is on our site
    if /^http/.match url
      if /^http\:\/\/#{@site.name}/.match url
        true
      else
        false
      end
    elsif /^mailto\:/.match url
      false
    elsif /^javascript\:/.match url
      false
    else
      true
    end
  end
  
  def process_url(scan)
    puts "=> processing #{scan.url}"
    
    begin
      page = get_page scan.url
    rescue
      puts "  \033[35m=> Cannot find page #{scan.url}\033[0m"
      scan.content = $!
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
          actual += 1
          # puts "    => added #{new_url}"
        end
      end
    end
    
    scan.last_visited = Time.now
    scan.save!
    puts "  => queued #{all_links.count}/#{count}/#{actual} new urls for later"
  end
  
  def perform(host, ticket_no)
    @site = Site.find_by(name: host)
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