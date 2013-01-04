require 'spec_helper'

describe Silo do

  context 'simple silos' do
    subject { create(:project) }

    it "should persist a Silo" do
      subject.should be_persisted
      Silo.count.should eq(1)
    end

    it "should contain the name of the project" do
      subject.default_silo.should eq({"name" => subject.name})
    end

    it "should update the name if the name changes" do
      subject.name = Faker::Name.name
      subject.save
      subject.default_silo["name"].should eq(subject.name)
    end

    it "should delete the silo if the project is deleted" do
      subject.destroy
      Silo.count.should eq(0)
    end

  end

  context "Custom Silo constructors:" do
    before do
      @complex_project = create(:complex_project)
    end

    it "Updates a silo on save" do
      @complex_project.name = Faker::Name.name
      @complex_project.save
      @complex_project.complex_silo["name"].should eq(@complex_project.name)
    end
  end

end