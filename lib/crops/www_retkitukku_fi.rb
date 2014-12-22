# -*- coding: UTF-8 -*-
require 'harvester'

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
    find xpath: '//div[@class="product-shop"]//span[starts-with(@id, "product-price-") and not(string-length(@id) > 20)]', as: :price_tag

    scrape :price_tag, only: :once do
      mandatory :h1_name
      name h1_name.text, :sort
      image_url pic_1.href
      price price_tag.text
    end
  end
  
  
  index :product do
    pid counter
    name
    price crop.price.strip
    url :origin_url
    image_id :image_url
    shop 'retkitukku'
  end
end