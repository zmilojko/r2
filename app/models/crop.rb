class Crop
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  field :origin_url, type: String
  field :harvest, type: String
  belongs_to :site
end
