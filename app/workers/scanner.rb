require 'rest_client'
STDOUT.sync = true

class Scanner
  include Sidekiq::Worker
  
  def initialize
    @cookies = nil
  end
  
  def full_url(url)
    if /https?\:\/\/#{@site.name}/.match url
      # this is a full url
      url
    else 
      "http#{}://#{@site.name}#{url[0] == "/" ? "" : "/"}#{url}"
    end
  end
  
  def get_page url
    # puts "  => wanting to get #{url}, full: #{full_url(url)}"
    response = RestClient.get full_url(url),
        user_agent: "re-bot",
        cookies: @cookies
    @cookies = response.cookies unless response.cookies.blank?
    
    unless @converter or @site.encoding.blank?
      # example of encoding: "ISO-8859-1"
      #TODO: should also try to read the value from the file
      @converter = Encoding::Converter.new(@site.encoding,"UTF-8")
    end
    response
  end
  
  def convert_to_utf page
    unless @site.encoding.blank?
      page = @converter.convert page
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
      new_url = link.attributes['href'].value
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
      
      @site.status = :on
      @site.save!
      
      next_scan = @site.scans.find_by(last_visited: nil)
      
      if next_scan.nil?
        puts "Completed scanning"
        @site.status = :off
        @site.save!
        break;
      end

      process_url next_scan
    end
    puts "Completed scanning task for #{@site.name}"
  end
end