class MakeComplexGrainBelt < MongoidSilo::GrainBelt
  def generate
    {
      name: name,
      due_date: due_date
    }
  end
end