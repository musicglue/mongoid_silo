FactoryGirl.define do
  factory :multi_silo_project do
    name { Faker::Name.name }
    city { Faker::Address.city }
    county { Faker::AddressUK.county }
  end
end