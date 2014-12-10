class Crop
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  field :harvest, type: String
  belongs_to :site
end
