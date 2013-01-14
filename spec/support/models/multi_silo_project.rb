class MultiSiloProject
  include Mongoid::Document
  include Mongoid::Silo

  field :name, type: String
  field :city, type: String
  field :county, type: String

  silo :name, generator: "MakeNameGrainBelt"
  silo :location, generator: "MakeLocationGrainBelt"

end