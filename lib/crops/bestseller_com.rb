# -*- coding: UTF-8 -*-
load 'harvester.rb'

# reload! ; s = Site.find_by name: "bestseller.com" ;  s.crops.delete_all ; k = s.harvester.perform_harvest ; g = s.crops ; k

class BestsellerCom < Harvester
  site "bestseller.com"

  filter only_for: :always do
    result = true
    %w(page-setcountry wishlist cart order history page-handover
       source=quickview payment customer contact).each do |w| 
      if url.downcase.include? w
        puts "getting out for #{url} on word #{w}"
        return false
      end
    end
    
    # http://bestseller.com/on/demandware.store/Sites-ROE-Site/en_GB/Search-Show?redirected=1&cgid=bc-kids-sale&forcecountry=FI&forcebrand=bestseller-com#/Storefront-Catalog---EN/root,en_GB,sc.html?prefn1=category-id&prefv1=ni-newborn-restsalg%7Cni-mini-restsalg%7Cni-kids-restsalg%7Cpc-greatoffers-little&prefn2=product-type-code&prefv2=0%7C1%7C4&prefn3=scopeFilter&prefv3=default&srule=bc-new-arrivals&start=96&sz=12&renderascategory=bc-kids-sale
    # must replace "start=96" with start=24, basically no matter what, reduce 72
    
    if url[/start=(\d{2,3})/] and url.include?("renderascategory=bc-kids-sale")
      puts "found page url for #{url}"
      result = { replace_url: url.gsub(/start=(\d{2,3})/) {|c| "start=#{c[/\d+/].to_i - 72}" } }
    else
      puts "found product url for #{url}"
      result = { replace_url: url.gsub(/\?.*$/,"") }
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
