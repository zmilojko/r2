# -*- coding: UTF-8 -*-
load 'harvester.rb'

# reload! ; s = Site.find_by name: "www.retkitukku.fi" ;  s.crops.delete_all ; k = s.harvester.perform_harvest ; g = s.crops ; k

class WwwRetkitukkuFi < Harvester
  site "www.retkitukku.fi"

  filter only_for: :always do
    result = true
    %w(index.php catalog checkout control contacts customer customize 
    newsletter poll review sendfriend tag wishlist cron.php cron.sh error
    install license media).each do |w| 
      if url[Regexp.new(w,"i")]
        result = false
        break
      end
    end
    result = false if url.downcase.include? "#"
    result = false if url.downcase.include? "?"
    puts "Testing retki url #{url}, result #{result}"
    result
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
