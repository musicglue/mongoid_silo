class MakeLocationGrainBelt < MongoidSilo::GrainBelt
  def generate
    {
      city: city,
      country: country
    }
  end
end