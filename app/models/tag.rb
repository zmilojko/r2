class Tag
  include Mongoid::Document
  field :name, type: String
  field :do_use_as_tag, type: Mongoid::Boolean, default: false
  field :do_use_as_keyword, type: Mongoid::Boolean, default: false
  field :do_use_as_product_description, type: Mongoid::Boolean, default: false
  field :do_ignore_word, type: Mongoid::Boolean, default: false
  embeds_many :keywords
  
#   index({ name: 1 })
#   index({"keywords.word" => 1})
  def processed
    do_use_as_tag or do_use_as_keyword or do_ignore_word or do_use_as_product_description
  end
  
  def self.generate_from site: nil
    raise "Must specify site" unless site
    if site.is_a? String
      site = Site.find_by name: site
    end
    site.crops.each do |c|
      c.name.downcase.split.each do |w|
        catch :keyword_processing do
          clear_word = w.gsub(/[®\,\(\)\:\/\"\"\–]+/,"")
          clear_word.gsub!(/^[\s\-\dx\.\ \ ]+/,"")
          clear_word.gsub!(/[\s\-\dx\.\ \ ]+$/,"")
          clear_word.gsub!(/\'s$/,"")
          clear_word.gsub!(/\'/,"")
          
          # ignore word if it does not contain any letters
          #unless clear_word[/[\d\s\.\-\_\,\'\"]+/] then throw :keyword_processing end
          unless clear_word[/\w{3,}/] then throw :keyword_processing end
          if clear_word.length < 4 then throw :keyword_processing end

          puts "Analyzing word #{clear_word}"
          Tag.find_or_create_by name: clear_word do
            puts "  => Created word #{clear_word}"
          end
        end
      end
    end
  end
  
  def self.dump_to_csv_file filename
    File.open(filename, 'w') do |file| 
      Tag.all.order_by(name: :asc).each do |tag|
        file.write(tag.name + "\n")
      end
    end
    Tag.all.count
  end
end
