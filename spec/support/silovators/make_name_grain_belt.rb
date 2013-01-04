class MakeNameGrainBelt < MongoidSilo::GrainBelt
  def generate
    {
      name: name
    }
  end
end