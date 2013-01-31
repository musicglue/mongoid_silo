class OtherCollectionProject
  include Mongoid::Document
  include Mongoid::Silo

  field :name

  silo :basic do |config|
    config.session    = :alternative
    config.collection = :dogs
    config.database   = :mongoid_silo_testing_2
  end
end