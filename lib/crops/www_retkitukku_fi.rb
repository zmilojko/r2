# -*- coding: UTF-8 -*-
require 'harvester'

# reload! ; require 'harvester' ; Harvester.set_debug true ; s = Site.find_by name: "www.retkitukku.fi" ;  s.crops.delete_all ; k = s.harvester.perform_harvest ; g = s.crops ; k

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
    result
  end
  
  harvest do
    find css: 'div.MagicToolboxContainer a.MagicZoomPlus', as: :pic_1
    find css: '.product-name h1', as: :h1_name
    find xpath: '//span[starts-with(@id, "product-price-") and not(string-length(@id) > 20)]', as: :price_tag
    # find xpath: '//span[starts-with(@id, "product-price-") and not(contains(@id, "clone")) and not(contains(@id, "related")) and not(contains(@id, "upsell"))]', as: :price_tag
    # find css: 'div.price-box span.price', as: :price_tag
    
    # c = s.scans.find_by url: "http://www.retkitukku.fi/alaska-mount-hunter-pro-untuvatakki.html"
    # c.html.css( "div.MagicToolboxContainer  a.MagicZoomPlus").href
    
    scrape :price_tag, only: :once do
      mandatory :h1_name
      name h1_name.text, :sort
      image_url pic_1.href
      price price_tag.text
    end
  end
end
