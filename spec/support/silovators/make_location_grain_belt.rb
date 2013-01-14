class MakeLocationGrainBelt < MongoidSilo::GrainBelt
  def generate
    {
      city: city,
      county: county
    }
  end
end