# -*- coding: UTF-8 -*-
load 'harvester.rb'

# reload! ; s = Site.find_by name: "www.hm.com" ;  s.crops.delete_all ; k = s.harvester.perform_harvest ; g = s.crops ; k

class WwwHmCom < Harvester
  site "www.hm.com"

  filter only_for: :always do
    u = url.downcase
    
    result = referral.downcase.include? "subdepartment/sale"
    %w(pra1 goes_with_pd similar_to_sd index.php checkout 
    control contacts customer customize 
    newsletter review sendfriend wishlist error
    install license media webapp order logon userreg 
    inspiration ).each do |w| 
      if u.include? w
        result = false
      end
      break unless result
    end
    if result
      if u.include? "product"
        result = { replace_url: url.gsub(/\?.*/,"") }
      else
        if u[/\?page=\d+/]
          result = { replace_url: referral + url }
        else
          result = false
        end
      end
    end
    # puts "verdict for HM #{url} is #{result}"
    result
  end
  
  harvest do
    find css: 'form#product' do
      find css: 'h1', as: :product_name_block do
        find css: 'span.price', as: :product_price do
          find css: 'span.new', as: :product_price_new
        end
      end
    end

    scrape :product_name_block do
      name form.css('h1 > text()').text.strip, :sort
      price (node_found?(:product_price_new) ? self.product_price_new.text : self.product_price.text).strip
    end
  end
end
