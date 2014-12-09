# reload! ; load 'vets.rb' ; g = parsevets ; g.count

#  h = Scan.find_by(url:"/19").html.css('td.content_table').css('p'); 7

$dev_debug = true

def check?
  begin
    yield
  rescue
    nil
  end
end

module Scraper 
  def scrape **actions
    self.map do |x|
      begin
        Thread.current.thread_variable_set('element', x)
        y = yield x
        if actions[:mandatory]
          mandatory = actions[:mandatory]
          mandatory = [mandatory] unless mandatory.class == Array
          next unless mandatory.all? {|v| y[v]}
        end
        y
      rescue
        if $dev_debug
          scan = Thread.current.thread_variable_get('scan')
          puts scan.url if scan
          elem = Thread.current.thread_variable_get('element')
          puts elem if elem
          puts "Error: #{$!}"
        end
      end
    end.compact.flatten
  end
  
  # name = p.css('a').text if (name = p.css('strong').text).empty?
  def css_any *criteria
    criteria.each do |c|
      unless (res = css(c)).empty?
        return res
      end
    end
    nil
  end
  
  def href
    check? { css('a')[0]['href'] }
  end
end


class Boo
  def remember &block
    @proc = block
  end
  
  def exec
    @proc.call
  end
end


class Scraperer
  @@site_name = nil
  @@filters = []
  @@analyses = []
  
  def self.site name
    @@site_name = name
  end
  
  def self.filter only_for: nil, regex: nil, &block
    if block
      raise "cannot have both regex and block in same filter" if regex
      filter_proc = block
    else
      filter_proc = Proc.new {|url| url.match regex }
    end
    @@filters << { 
      only_for: [only_for],
      block: filter_proc
    }
  end
  
  def self.analyze name: nil, &block
    raise "you should define site name before defining analysis" unless @@site_name
    @@analyses << {
      name: name || @@site_name,
      block: block
      }
  end
end

class Vet < Scraperer
  site "www.suomenelaintuhkaus.fi"
  # here can make filter when: :scraping, :crowling, :always (default)
  filter only_for: :scraping do |url|
    url[/\/\d{2}/][/\d+/].to_i.between?(11,55)
  end
  
  # possible to give name: 'some_name', that will be remembered in the database
  # that could also be the only parameter, and the rest in the block
  analyze do
    find css: 'td.content_table' do # as: :td
      find css: 'p' # as :p', note that this is inside :td block
    end

    scrape do
      city td.css('h1').text, :mandatory
      name p.css_any('a', 'strong').text, :mandatory, :sort
      url p.href
      info p.text
      # origin scan.url
    end
    
    # later to consider: link backtrace!
    # this could be done by giving scraping seeds and then following 
    # links only from there
    # That could be made by making a FOLLOW command that could be used with
    # with FIND command
  end
end


def parsevets
  Site["www.suomenelaintuhkaus.fi"].scans.scrape do |scan|
    Thread.current.thread_variable_set('scan', scan)
    next unless check? { scan.url[/\/\d{2}/][/\d+/].to_i.between?(11,55) }
    puts "checking scan #{scan.url}"
    scan.html.css('td.content_table').scrape do |td|
      td.css('p').scrape mandatory: [:name, :city] do |p|
        {
          city: td.css('h1').text,
          name: p.css_any('a', 'strong').text,
          url: p.href,
          info: p.text,
          origin: scan.url
        }
      end
    end
  end.sort_by {|x| x[:name]}
end

class Nokogiri::XML::NodeSet
  include Scraper
end
class Nokogiri::XML::Element
  include Scraper
end
class  Mongoid::Relations::Targets::Enumerable
  include Scraper
end

