# -*- coding: UTF-8 -*-
require 'harvester'

# reload! ; s = Site.find_by name: "kauppa.ouluvet.fi" ;  s.crops.delete_all ; k = s.harvester.perform_harvest ; g = s.crops ; k

class KauppaOuluvetFi < Harvester
  site "kauppa.ouluvet.fi"

  filter only_for: :always do
    url[/index\.php\?main_page\=index/] or
      url[/index\.php\?main_page\=product_info/]
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
