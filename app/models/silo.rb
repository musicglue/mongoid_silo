require 'mongoid'

class Silo
  include Mongoid::Document
  include Mongoid::Timestamps

  field :item_class, type: String
  field :item_id, type: String
  field :silo_type, type: String
  field :bag

  index item_class: 1
  index item_id: 1
  index silo_type: 1

  def to_json
    @json ||= MultiJson.encode bag
  end

  class << self
    def for_id_and_class_with_name item_id, class_name, silo_name
      where(item_class: class_name, item_id: item_id, silo_type: silo_name).first
    end

    def for_id_and_name_with_no_class item_id, silo_name
      where(item_id: item_id, silo_type: silo_name).first
    end
  end
end
