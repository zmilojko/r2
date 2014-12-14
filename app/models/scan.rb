class Scan
  include Mongoid::Document
  field :url, type: String
  field :content, type: String
  field :last_visited, type: Time, default: nil
  field :seed, type: Mongoid::Boolean, default: false
  field :referral
  field :scanning_error
  belongs_to :site
  
  def never_visited
    last_visited.nil?
  end
  def never_visited= value
    if value.nil?
      last_visited = nil
    else
      last_visited = DateTime.now if last_visited.nil?
    end
  end
  
  def html
    Nokogiri::HTML(content)
  end
end
