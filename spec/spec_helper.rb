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

  Mongoid.load!(File.expand_path("../mongoid.yml", __FILE__), :test)

  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
    config.filter_run :focus => true  
    config.run_all_when_everything_filtered = true
    config.backtrace_clean_patterns << /gems\//

    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
      DatabaseCleaner[:mongoid, {connection: :mongoid_silo_testing_2}].clean
    end
  end

  
end

Spork.each_run do
  require 'mongoid_silo'
  FactoryGirl.find_definitions
  # Dir['./app/**/*.rb'].each { |file| require file }
  Dir['./spec/support/**/*.rb'].each{ |file| require file }
end










