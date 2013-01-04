class ComplexProject
  include Mongoid::Document
  include Mongoid::Silo

  field :name, type: String
  field :due_date, type: DateTime


  silo :complex, generator: "MakeComplexGrainBelt"

end