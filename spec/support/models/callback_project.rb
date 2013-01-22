class CallbackProject
  include Mongoid::Document
  include Mongoid::Silo
  
  field :name
  
  silo :basic do |config|
    config.callback = :triggered
  end
  
  def triggered context
    self.class.triggered
  end
  
  def self.triggered 
    true
  end
end