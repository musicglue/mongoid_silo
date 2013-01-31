class CallbackProject
  include Mongoid::Document
  include Mongoid::Silo
  
  field :name
  
  has_many :block_project_items

  silo :basic do |config|
    config.callback = :triggered
    # config.dependents << {class_name: "String", foreign_key: "owner_id", condition: "published"}
  end

  
  def triggered context
    self.class.triggered
  end
  
  def self.triggered 
    true
  end
end