class MakeVersionedProjectGrainBelt < MongoidSilo::GrainBelt
  version 1 do
    { foo: "bar" }
  end

  version 2 do
    { foo: "baz" }
  end
end
