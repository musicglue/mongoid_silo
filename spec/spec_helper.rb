require 'rubygems'
require 'bundler/setup'
require 'spork'
require 'guard/rspec'
require 'rspec'

Spork.prefork do
  require 'sidekiq'
  require 'mongoid'
  require 'factory_girl'
  require 'database_cleaner'
  require 'ffaker'
  require 'sidekiq/testing/inline'
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  

  Mongoid.load!(File.expand_path("../mongoid.yml", __FILE__), :test)



  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
    config.filter_run :focus => true  
    config.run_all_when_everything_filtered = true

    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  end

  
end

Spork.each_run do
  require 'mongoid_silo'
  FactoryGirl.find_definitions
  # Dir['./app/**/*.rb'].each { |file| require file }
  Dir['./spec/support/**/*.rb'].each{ |file| require file }
end










