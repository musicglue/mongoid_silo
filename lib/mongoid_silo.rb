require "mongoid_silo/version"
require 'mongoid_silo/railtie' if defined?(Rails)
require 'mongoid/silo'
require 'models/silo'
require 'workers/mongoid_silo/update_silo_worker'

module MongoidSilo
end
