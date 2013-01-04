require 'rubygems'
require 'bundler/setup'
require 'spork'
require 'guard/rspec'
require 'rspec'


Spork.prefork do
  require 'mongoid_silo'
  require 'factory_girl'
  require 'database_cleaner'
  require 'faker'
  require 'sidekiq/testing/inline'
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  FactoryGirl.find_definitions


  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods

    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  end

  Mongoid.load!(File.expand_path("../mongoid.yml", __FILE__), :test)

  require 'support/models/project'
  require 'support/models/complex_project'
end

Spork.each_run do
  # This code will be run each time you run your specs.

end










