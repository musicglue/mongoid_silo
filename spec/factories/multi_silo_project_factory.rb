FactoryGirl.define do
  factory :multi_silo_project do
    name { Faker::Name.name }
    city { Faker::Address.city }
    country { Faker::Address.country }
  end
end