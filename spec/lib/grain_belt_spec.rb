require 'spec_helper'

describe MongoidSilo::GrainBelt do
  context "Instantiated with a simple model" do
    before do
      @model = create(:project)
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

  context "versioning" do
    let(:klass) do
      Class.new(described_class)
    end

    before do
      klass.versioned_generators_store = {}
    end

    it "adds a block to the version hash" do
      klass.version(1) do
        "foo"
      end

      klass.versioned_generators[1].call == "foo"
    end

    it "allows multiple versions to be defined at once" do
      klass.version(1, 2, 3) do
        "foo"
      end

      received = []

      klass.versioned_generators.each do |version, proc|
        received << "foo"
      end

      received.should == ["foo", "foo", "foo"]
    end

    it "supports subclassing" do
      klass.version(1, 2, 3) do
        "foo"
      end

      subclass = Class.new(klass)

      subclass.versioned_generators[1].call.should == "foo"
    end
  end
end

