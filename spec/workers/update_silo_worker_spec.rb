require 'spec_helper'

describe MongoidSilo::UpdateSiloWorker do

  context "Project is not persisted - Defaults:" do
    before do
      @project = build(:project)
    end

    it "Creates a silo on save if none exist" do
      @project.save
      Silo.count.should eq(1)
    end

    it "populate the silo according to #to_silo" do
      @project.save
      @project.default_silo.should eq({"name" => @project.name})
    end
  end

end