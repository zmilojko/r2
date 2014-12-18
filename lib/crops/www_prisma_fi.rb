# -*- coding: UTF-8 -*-
load 'harvester.rb'

# reload! ; s = Site.find_by name: "www.prisma.fi" ;  s.crops.delete_all ; k = s.harvester.perform_harvest ; g = s.crops ; k

class WwwPrismaFi < Harvester
  site "www.prisma.fi"

  # http://www.prisma.fi/fi/SearchDisplay?searchTermScope=&searchType=&filterTerm=&orderBy=8&maxPrice=&showResultsPage=true&beginIndex=24&langId=-11&sType=SimpleSearch&metaData=&pageSize=&manufacturer=&resultCatEntryType=&catalogId=11202&pageView=image&searchTerm=&minPrice=&urlLangId=-11&categoryId=73904&storeId=11851
  
  # but not: http://www.prisma.fi/fi/SearchDisplay?searchTermScope=&searchType=1002&filterTerm=&maxPrice=&showResultsPage=true&langId=-11&beginIndex=0&sType=SimpleSearch&metaData=&pageSize=&manufacturer=&resultCatEntryType=&catalogId=11202&pageView=image&searchTerm=&facet=mfName_ntk_cs%253A%2522De%2BLonghi%2522&minPrice=&categoryId=73911&storeId=11851
  
  filter only_for: :always do
    result = (url.downcase.include?("osasto") or referral.downcase.include?("osasto"))
    # puts "Referal is #{referral}, url is #{url}, first verdict is #{result}"
    if result 
      if url.downcase.include?("search")
        result = false
        # puts "Checking pages"
        (1..9).each do |n|
          if url.downcase.include? "beginindex=#{n}"
            result = true
            break
          end
        end
        # puts "Pages say: #{result}"
      else    
#         puts "Referal is #{referral}, url is #{url}, first verdict is #{result}"
        %w(mainokset ostoskori haku logon logoff order checkout shipment image
          palvelut myymala).each do |w| 
          if url[Regexp.new(w,"i")]
            result = false
            break
          end
        end
      end
    end
    result = false if url[0] == "#"
#     puts "Referal is #{referral}, url is #{url}, final verdict is #{result}"
    result
  end
  
  harvest do
    # find css: 'td.content_table' do
    #   find css: 'p'
    # end
#     find css: 'div.MagicToolboxContainer a.MagicZoomPlus', as: :pic_1
#     find css: '.product-name h1', as: :h1_name
#     find xpath: '//div[@class="product-shop"]//span[starts-with(@id, "product-price-") and not(string-length(@id) > 20)]', as: :price_tag
#     # find xpath: '//span[starts-with(@id, "product-price-") and not(contains(@id, "clone")) and not(contains(@id, "related")) and not(contains(@id, "upsell"))]', as: :price_tag
#     # find css: 'div.product-shop div.price-box span.price', as: :price_tag
#     
#     # c = s.scans.find_by url: "http://www.retkitukku.fi/alaska-mount-hunter-pro-untuvatakki.html"
#     # c.html.css( "div.MagicToolboxContainer  a.MagicZoomPlus").href
#     
#     scrape :price_tag, only: :once do
#       mandatory :h1_name
#       name h1_name.text, :sort
#       image_url pic_1.href
#       price price_tag.text
#     end
  end
end

