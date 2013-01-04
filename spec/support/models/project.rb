class Project
  include Mongoid::Document
  include Mongoid::Silo

  field :name, type: String

  silo
  
end