class MultiSiloProject
  include Mongoid::Document
  include Mongoid::Silo

  field :name, type: String
  field :city, type: String
  field :country, type: String

  silo :name, :make_name_silo
  silo :location, :make_location_silo

  def make_name_silo; {name: name}; end
  def make_location_silo
    {
      city: city,
      country: country
    }
  end

end