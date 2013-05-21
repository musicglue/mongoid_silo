class VersionedProject
  include Mongoid::Document
  include Mongoid::Silo

  silo :foobar do |conf|
    conf.generator = "MakeVersionedProjectGrainBelt"
  end
end

