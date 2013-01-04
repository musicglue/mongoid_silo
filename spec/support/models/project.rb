class Project
  include Mongoid::Document
  include Mongoid::Silo

  field :name, type: String

  silo

  def to_silo
    {
      name: name
    }
  end
end