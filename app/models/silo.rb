require 'mongoid'

class Silo
  include Mongoid::Document
  include Mongoid::Timestamps

  field :item_class, type: String
  field :item_id, type: String
  field :silo_type, type: String
  field :bag, type: Hash


  index item_class: 1
  index item_id: 1
  index silo_type: 1
end