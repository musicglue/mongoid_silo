class ComplexProject
  include Mongoid::Document
  include Mongoid::Silo

  field :name, type: String
  field :due_date, type: DateTime


  silo :complex, :make_complex_silo

  def make_complex_silo
    {
      name: name,
      due_date: due_date
    }
  end
end