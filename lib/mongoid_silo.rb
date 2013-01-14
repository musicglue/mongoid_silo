require "mongoid_silo/version"
require 'mongoid_silo/railtie' if defined?(Rails)
require 'mongoid_silo/grain_belt'
require 'mongoid/silo'
require_relative "../app/models/silo"
require_relative "../app/workers/mongoid_silo/update_silo_worker"

module MongoidSilo
end
