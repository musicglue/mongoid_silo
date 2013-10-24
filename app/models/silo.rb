require 'mongoid'

class Silo
  include Mongoid::Document
  include Mongoid::Timestamps

  field :item_class, type: String
  field :item_id, type: String
  field :silo_type, type: String
  field :bag, type: Hash
  field :version, type: Integer, default: 1

  index({ item_id: 1, silo_type: 1, version: 1 }, { unique: true })
  index silo_type: 1

  def to_json
    @json ||= MultiJson.encode bag
  end

  class << self
    def for_id_and_class_with_name(item_id, class_name, silo_name, version: 1)
      harvest(item_id, silo_name, class_name: class_name, version: version)
    end

    def for_id_and_name_with_no_class(item_id, silo_name, version: 1)
      harvest(item_id, silo_name, version: version)
    end

    def harvest(item_id, silo_name, class_name: nil, version: 1)
      query = {
        item_class: class_name,
        item_id: item_id,
        silo_type: silo_name,
        version: version
      }

      query = query.delete_if { |field, param| param.nil? }

      where(query).first
    end
  end
end

