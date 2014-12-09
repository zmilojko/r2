# reload! ; load 'vets.rb'

#  h = Scan.find_by(url:"/19").html.css('td.content_table').css('p'); 7

$dev_debug = true

module Scraper
  def scrape
    self.map do |x|
      begin
        yield x
      rescue
        puts $error if $dev_debug
      end
    end.compact.flatten
  end
end


def parsevets
  results = Site["www.suomenelaintuhkaus.fi"].scans.scrape do |scan|
    next unless scan.url[/\/\d{2}/] && scan.url[/\/\d{2}/][/\d+/].to_i.between?(11,55)
    # puts "checking scan #{scan.url}"
    scan.html.css('td.content_table').scrape do |td|
      next if td.css('h1').text.empty?
      td.css('p').scrape do |p|
        name = p.css('a').text if (name = p.css('strong').text).empty?
        next if name.empty?
        url = url['href'] if url = p.css('a')[0]
        # puts "#{name}, #{url}"
        {
          name: name,
          url: url,
          info: p.text,
          origin: scan.url
        }
      end
    end
  end
  
  results.sort {|l,r| l[:name]<=>r[:name]}
end

class Nokogiri::XML::NodeSet
  include Scraper
end
class  Mongoid::Relations::Targets::Enumerable
  include Scraper
end

  

def parse name
end