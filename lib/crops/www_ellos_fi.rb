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
    inspiration javascript).each do |w| 
      if url.downcase.include? w
        result = false
        break
      end
    end
    if result 
      if url[/\/ale\?nao\=\d+/i]
        result = true
      else
        if (not url.downcase.include? 'ale') and (not url.downcase.include? 'selArt')
          result = { replace_url: url.gsub(/\?.*/,"") }
        else
          result = false
        end
      end
    end    
    # puts "verdict for #{url} is #{result}"
    result
  end
  
  harvest do
    find css: 'div#details-wrapper' do
      find css: 'h1', as: :product_name
      find css: 'span.price', as: :product_price_new
    end

    scrape :product_name do
      name product_name.text, :sort
      price ((defined? product_price_new) ? product_price_new.text : product_price.text)
    end
  end
end

#http://www.ellos.fi/ellos-sport/urheiluliivit-teknista-materiaalia/415784?N=1z13t3o&Ns=RankValue4|1&Nao=50&selArt=170211
