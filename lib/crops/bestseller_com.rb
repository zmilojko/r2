# -*- coding: UTF-8 -*-
load 'harvester.rb'

# reload! ; s = Site.find_by name: "bestseller.com" ;  s.crops.delete_all ; k = s.harvester.perform_harvest ; g = s.crops ; k

class BestsellerCom < Harvester
  site "bestseller.com"

  filter only_for: :always do
    result = true
    %w(page-setcountry wishlist cart order history page-handover
       source=quickview storefront).each do |w| 
      if url.downcase.include? w
        result = false
        break
      end
    end
    result
  end

  # http://bestseller.com/name-it/tops-l-s/newborn-asi-slim-top/13113190,en_GB,pd.html?dwvar_13113190_colorPattern=13113190_CloudDancer&forceScope=
  
  # http://bestseller.com/name-it/dresses/newborn-anna-slim-tunic/13113189,en_GB,pd.html?dwvar_13113189_colorPattern=13113189_DressBlues#lcgid=bc-kids-sale
  
  # http://bestseller.com/name-it/scarves/kids-ycandy-scarf/13102050,en_GB,pd.html?dwvar_13102050_colorPattern=13102050_Black&forceScope=
  
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
