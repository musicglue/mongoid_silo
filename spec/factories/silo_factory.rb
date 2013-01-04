FactoryGirl.define do
  factory :silo do
    item_id     { Moped::BSON::ObjectId.new }
    item_class  "ClassName"
    silo_type   "default"
    bag         Hash.new
  end
end