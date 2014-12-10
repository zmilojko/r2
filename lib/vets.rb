# -*- coding: UTF-8 -*-

if $dev_debug
  load 'harvester.rb'
else
  require 'harvester'
end

class Vet < Harvester
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


def parsevets
  Site["www.suomenelaintuhkaus.fi"].scans.scrape2 do |scan|
    Thread.current.thread_variable_set('scan', scan)
    next unless check? { scan.url[/\/\d{2}/][/\d+/].to_i.between?(11,55) }
    puts "checking scan #{scan.url}"
    scan.html.css('td.content_table').scrape2 do |td|
      td.css('p').scrape2 mandatory: [:name, :city] do |p|
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



