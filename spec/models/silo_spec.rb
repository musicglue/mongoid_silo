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

  context 'Direct finders and methods:' do
    before do
      @project1 = create(:project)
      @project2 = create(:project)
      @project3 = create(:complex_project)
    end

    it "should find by id and silo type" do
      found = Silo.for_id_and_name_with_no_class(@project1.id.to_s, "default")
      found.should_not be_nil
    end

    it "should find by id and class and silo type" do
      found = Silo.for_id_and_class_with_name(@project1.id.to_s, @project1.class.to_s, "default")
      found.should_not be_nil
    end

    it "should find complex documents" do
      found = Silo.for_id_and_class_with_name(@project3.id.to_s, @project3.class.to_s, "complex")
      found.should_not be_nil
    end

    it "should not find where no match exists" do
      found = Silo.for_id_and_class_with_name("wombats", "aren't", "real")
      found.should be_nil
    end

    it "should serialize to JSON correctly" do
      found = Silo.for_id_and_class_with_name(@project1.id.to_s, @project1.class.to_s, "default")
      MultiJson.decode("#{found.to_json}").should be_a(Hash)
    end
  end

  context "Custom Silo constructors:" do
    before do
      @complex_project = create(:complex_project)
    end

    it "defines an accessor based on the declared silo name" do
      @complex_project.should respond_to(:complex_silo)
    end

    it "updates a silo on save" do
      @complex_project.name = Faker::Name.name
      @complex_project.save
      @complex_project.complex_silo["name"].should eq(@complex_project.name)
    end

    it "removes the custom silo on destroying the project" do
      @complex_project.destroy
      Silo.count.should eq(0)
    end
  end

  context "Multiple silo constructors:" do
    before do
      @multi_silo_project = create(:multi_silo_project)
    end

    it "Creates two silos" do
      Silo.count.should eq(2)
    end

    it "Correctly populates the Name silo" do
      _expectation = {
        "name" => @multi_silo_project.name
      }
      @multi_silo_project.name_silo.should eq(_expectation)
    end

    it "Correctly populates the Location silo" do
      _expectation = {
        "city" => @multi_silo_project.city,
        "country" => @multi_silo_project.country
      }
      @multi_silo_project.location_silo.should eq(_expectation)
    end

    it "Correctly updates both silos" do
      @multi_silo_project.city    = Faker::Address.city
      @multi_silo_project.country = Faker::Address.country
      @multi_silo_project.name    = Faker::Name.name
      @multi_silo_project.save
      _name_silo_expectation = {
        "name" => @multi_silo_project.name
      }
      _location_silo_expectation = {
        "city" => @multi_silo_project.city,
        "country" => @multi_silo_project.country
      }
      @multi_silo_project.name_silo.should eq(_name_silo_expectation)
      @multi_silo_project.location_silo.should eq(_location_silo_expectation)
    end

    it "Destroys both silos when project is deleted" do
      @multi_silo_project.destroy
      Silo.count.should eq(0)
    end
  end

end