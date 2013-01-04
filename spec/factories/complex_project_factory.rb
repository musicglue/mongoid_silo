FactoryGirl.define do
  factory :complex_project do
    name { Faker::Name.name }
    due_date { DateTime.now }
  end
end