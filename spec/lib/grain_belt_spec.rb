require 'spec_helper'

describe MongoidSilo::GrainBelt do
  context "Instantiated with a simple model" do

    before do
      @model = build(:project)
      @silovator = MongoidSilo::GrainBelt.new(@model)
    end

    it "exposes the model's properties without prefixing" do
      @silovator.name.should eq(@model.name)
    end

    it "exposes the model through the object accessor" do
      @silovator.object.should eq(@model)
    end

    it "generates a hash for storing in the silo" do
      @silovator.generate.should be_a(Hash)
    end

  end
end