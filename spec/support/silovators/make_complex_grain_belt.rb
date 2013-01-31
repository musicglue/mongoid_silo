class MakeComplexGrainBelt < MongoidSilo::GrainBelt
  def generate
    {
      name: name,
      due_date: due_date.to_time
    }
  end
end