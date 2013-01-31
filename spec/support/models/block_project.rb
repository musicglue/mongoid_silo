require_relative './block_project_item'
class BlockProject
  include Mongoid::Document
  include Mongoid::Silo

  silo :block do |conf|
    conf.generator = "MakeBlockProjectGrainBelt"
    conf.dependents << { class_name: "BlockProjectItem" }
    conf.session = :default
  end

  field :name, type: String
  has_many :block_project_items
end