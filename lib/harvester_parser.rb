# -*- coding: UTF-8 -*-

module Scraper
  def css_any *criteria
    criteria.each do |c|
      unless (res = css(c)).empty?
        return res
      end
    end
    nil
  end

  def href
    begin
      css('a')[0]['href']
    rescue
      begin
        attribute('href').value
      rescue
        nil
      end
    end
  end
end

class Nokogiri::XML::NodeSet
  include Scraper
end
class Nokogiri::XML::Element
  include Scraper
end
