class Keyword
  include Mongoid::Document
  field :word, type: String
  embedded_in :tag
end
