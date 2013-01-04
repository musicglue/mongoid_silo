require "mongoid_silo/version"
require 'mongoid_silo/railtie' if defined?(Rails)
require 'mongoid_silo/grain_belt'
require 'mongoid/silo'

Dir['./app/**/*.rb'].each{ |file| require file }

module MongoidSilo
end
