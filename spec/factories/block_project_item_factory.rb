FactoryGirl.define do
  factory :block_project_item do
    name                { Faker::Name.name }
    block_project_id    { nil }
  end
end