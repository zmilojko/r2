class Rule
  include Mongoid::Document
  field :regex, type: String
  field :positive, type: Mongoid::Boolean
  field :order, type: Integer
  embedded_in :site
end
