class MultiSiloProject
  include Mongoid::Document
  include Mongoid::Silo

  field :name, type: String
  field :city, type: String
  field :country, type: String

  silo :name, silovator: "MakeNameGrainBelt"
  silo :location, silovator: "MakeLocationGrainBelt"

end