# -*- coding: UTF-8 -*-
load 'harvester.rb'

# reload! ; s = Site.find_by name: "www.ellos.fi" ;  s.crops.delete_all ; k = s.harvester.perform_harvest ; g = s.crops ; k

class WwwEllosFi < Harvester
  site "www.ellos.fi"

  filter only_for: :always do
    result = referral.include? 'ale'
    %w(index.php catalog checkout control contacts customer customize 
    newsletter poll review sendfriend tag wishlist cron.php cron.sh error
    install license media webapp order logon userreg kaupat ohjeet www 
    inspiration).each do |w| 
      if url[Regexp.new(w,"i")]
        result = false
        break
      end
    end
    result = false if url.downcase.include? "#"
    result = false if url.downcase.include? "?"
    result = false if url.downcase.include? "."
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
