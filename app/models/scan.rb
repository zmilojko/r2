class Scan
  include Mongoid::Document
  field :url, type: String
  field :actual_url, type: String
  field :content, type: String
  field :last_visited, type: Time, default: nil
  field :seed, type: Mongoid::Boolean, default: false
  field :referral
  field :scanning_error
  belongs_to :site
  
  index({ site: 1, last_visited: 1 }, { background: true })
  index({ site: 1, url: 1 }, { background: true })
  
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

  def full_url
    actual_url.blank? ? url : actual_url
  end
  
  def self.url_token url
    if url.length > 800
      url.hash.to_s
    else
      url
    end
  end
end
