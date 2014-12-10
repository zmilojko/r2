# -*- coding: UTF-8 -*-

def check?
  begin
    yield
  rescue
    nil
  end
end

module Scraper

  def scrape2 **actions
    self.map do |x|
      begin
#         Thread.current.thread_variable_set('element', x)
        y = yield x
        
        if actions[:mandatory]
          mandatory = actions[:mandatory]
          mandatory = [mandatory] unless mandatory.class == Array
          next unless mandatory.all? {|v| y[v]}
        end
        y
      rescue
        if $dev_debug
#           scan = Thread.current.thread_variable_get('scan')
#           puts scan.url if scan
#           elem = Thread.current.thread_variable_get('element')
#           puts elem if elem
          puts "Error in Scraper: #{$!}"
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

class Nokogiri::XML::NodeSet
  include Scraper
end
class Nokogiri::XML::Element
  include Scraper
end
class  Mongoid::Relations::Targets::Enumerable
 include Scraper
end