# -*- coding: UTF-8 -*-

require 'harvester'

# reload! ; require 'harvester' ; Harvester.set_debug true ; s = Site.find_by name: "www.suomenelaintuhkaus.fi" ;  s.crops.delete_all ; k = s.harvester.perform_harvest ; g = s.crops ; k


class WwwSuomenelaintuhkausFi < Harvester
  site "www.suomenelaintuhkaus.fi"
  # here can make filter when: :harvesting, :crowling, :always (default)
  filter only_for: :harvesting do
    url[/\/\d{2}/][/\d+/].to_i.between?(11,55)
  end
  
  # possible to give name: 'some_name', that will be remembered in the database
  # that could also be the only parameter, and the rest in the block
  harvest do
    find css: 'td.content_table' do # as: :td
      find css: 'p' # as :p', note that this is inside :td block
    end

    scrape :p do
      city td.css('h1').text, :mandatory
      name p.css_any('a', 'strong').text, :sort
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
