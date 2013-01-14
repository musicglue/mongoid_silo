class BlockProjectItem
  include Mongoid::Document

  field :name, type: String

  belongs_to :block_project

end