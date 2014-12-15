# -*- coding: UTF-8 -*-
require 'harvester'

# reload! ; s = Site.find_by name: "www.lidl.fi" ;  s.crops.delete_all ; k = s.harvester.perform_harvest ; g = s.crops ; k

class WwwLidlFi < Harvester
  site "www.lidl.fi"

  filter only_for: :always do
    url.include? "/fi/tarjoukset.htm"
  end
  
  harvest do
    # find css: 'td.content_table' do
    #   find css: 'p'
    # end

    # scrape :p do
    #   city td.css('h1').text, :mandatory
    #   name p.css_any('a', 'strong').text, :sort
    #   url p.href
    #   info p.text
    # end
  end
end
