class ComplexProject
  include Mongoid::Document
  include Mongoid::Silo

  field :name, type: String
  field :due_date, type: DateTime


  silo :complex do |config|
    config.generator = "MakeComplexGrainBelt"
  end

end