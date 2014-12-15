# -*- coding: UTF-8 -*-
load 'harvester.rb'

# reload! ; s = Site.find_by name: "www.hm.com" ;  s.crops.delete_all ; k = s.harvester.perform_harvest ; g = s.crops ; k

class WwwHmCom < Harvester
  site "www.hm.com"

  filter only_for: :always do
    u = url.downcase
    
    result = true
    %w(index.php checkout control contacts customer customize 
    newsletter review sendfriend wishlist error
    install license media webapp order logon userreg 
    inspiration).each do |w| 
      if u.include? w
        result = false
      end
    end
    result ||= referral.downcase.include? "department/sale"
    if result
      if u.include? "product"
        result = { replace_url: url.gsub(/\?.*/,"") }
      else
        result = u.include? "department/sale"
      end
    end
    if result
      result = false if url.include?("PRA1#") or url.include?("GOES_WITH_PD#")
    end

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
