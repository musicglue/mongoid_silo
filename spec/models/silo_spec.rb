require 'spec_helper'

describe Silo do
  context 'simple silos' do
    before do
      @project = create(:project)
    end

    it "should persist a Silo" do
      @project.should be_persisted
      Silo.count.should eq(1)
    end

    it "assigns a default version of 1" do
      Silo.first.version.should eq(1)
    end

    it "should contain the name of the project" do
      @project.default_silo.should eq({"name" => @project.name})
    end

    it "should update the name if the name changes" do
      @project.name = Faker::Name.name
      @project.save
      @project.default_silo["name"].should eq(@project.name)
    end

    it "should delete the silo if the project is deleted" do
      @project.destroy
      Silo.count.should eq(0)
    end
  end

  context 'versioned silo' do
    before do
      @project = VersionedProject.create
    end

    it "should persist a Silo" do
      @project.should be_persisted
      Silo.count.should eq(2)
    end

    it "assigns the correct version to the generated silos" do
      Silo.all.map(&:version).should == [1, 2]
    end

    it "assigns the correct attributes to the first silo" do
      Silo.where(version: 1).first.bag.should == { "foo" => "bar" }
    end

    it "assigns the correct attributes to the second silo" do
      Silo.where(version: 2).first.bag.should == { "foo" => "baz" }
    end

    it "should delete the silos if the project is deleted" do
      @project.destroy
      Silo.count.should eq(0)
    end

    describe "#for_id_and_class_with_name" do
      it "supports querying specific versions" do
        args = [@project.id.to_s, @project.class.name, "foobar", version: 2]

        Silo.for_id_and_class_with_name(*args).bag.should == {
          "foo" => "baz"
        }
      end
    end

    describe "#for_id_and_name_with_no_class" do
      it "supports querying specific versions" do
        args = [@project.id.to_s, "foobar", version: 2]

        Silo.for_id_and_name_with_no_class(*args).bag.should == {
          "foo" => "baz"
        }
      end
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
      ActiveSupport::JSON.decode("#{found.to_json}").should be_a(Hash)
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

  context "Block based constructors:" do
    subject(:block_project) { create(:block_project) }

    it "defines an accessor based on the declared silo name" do
      block_project.should respond_to(:block_silo)
    end

    it "should create the required silo" do
      block_project.block_silo["name"].should eq(block_project.name)
    end

    it "updates the parent when a child is saved" do
      project_item = create(:block_project_item, block_project_id: block_project.id)

      block_project.block_silo["items"][0]["name"].should eq(project_item.name)
    end

    it "updates the parent when a child is updated" do
      project_item = create(:block_project_item, block_project_id: block_project.id)
      project_item.name = Faker::Name.name
      project_item.save

      block_project.block_silo["items"][0]["name"].should eq(project_item.name)
    end

    it "updates when there are many children" do
      project_item1 = create(:block_project_item, block_project_id: block_project.id)
      project_item2 = create(:block_project_item, block_project_id: block_project.id)
      project_item3 = create(:block_project_item, block_project_id: block_project.id)
      block_project.block_silo["items"].length.should eq(3)

      project_item2.name = Faker::Name.name
      project_item2.save

      bp = BlockProject.find block_project.id

      bp.block_silo["items"].map{|i| i["name"]}.sort.should eq(
        [project_item1.name, project_item2.name, project_item3.name].sort
      )
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
        "county" => @multi_silo_project.county
      }

      @multi_silo_project.location_silo.should eq(_expectation)
    end

    it "Correctly updates both silos" do
      @multi_silo_project.city   = Faker::Address.city
      @multi_silo_project.county = Faker::AddressUK.county
      @multi_silo_project.name   = Faker::Name.name
      @multi_silo_project.save

      _name_silo_expectation = {
        "name" => @multi_silo_project.name
      }

      _location_silo_expectation = {
        "city" => @multi_silo_project.city,
        "county" => @multi_silo_project.county
      }

      @multi_silo_project.name_silo.should eq(_name_silo_expectation)
      @multi_silo_project.location_silo.should eq(_location_silo_expectation)
    end

    it "Destroys both silos when project is deleted" do
      @multi_silo_project.destroy
      Silo.count.should eq(0)
    end
  end

  context "Callbacks" do
    subject(:project) { build(:callback_project) }

    it "should trigger a named callback" do
      CallbackProject.should_receive(:triggered)
      project.save
    end
  end
end
