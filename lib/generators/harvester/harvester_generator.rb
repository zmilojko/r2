require "harvester"

class HarvesterGenerator < Rails::Generators::NamedBase
  def create_files
    site_name = file_name
    s = Site.find_by name: site_name
    create_file "lib/crops/#{s.real_code_file_name}.rb", <<-FILE.strip_heredoc
      # -*- coding: UTF-8 -*-
      load 'harvester.rb'

      # reload! ; s = Site.find_by name: "#{site_name}" ;  s.crops.delete_all ; k = s.harvester.perform_harvest ; g = s.crops ; k

      class #{s.real_code_class_name} < Harvester
        site "#{site_name}"

        filter only_for: :harvesting do
          # url[/regex/].to_i.between?(11,55)
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
      FILE
  end
end
