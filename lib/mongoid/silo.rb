require 'active_support/concern'

module Mongoid
  module Silo
    extend ActiveSupport::Concern

    module ClassMethods
      def silo name=:default, versions={}, opts={}
        opts = if block_given?
          opts = ActiveSupport::OrderedOptions.new
          opts.dependents = []
          opts.callback = nil
          yield(opts)
          opts.generator ||= "MongoidSilo::GrainBelt"
          opts
        else
          opts, versions = versions, nil
          opts[:generator] ||= "MongoidSilo::GrainBelt"
          opts[:dependents] = []
          opts[:callback] = nil
          opts
        end
        opts[:session] = :default if opts[:session].nil?
        opts[:collection] = :silos if opts[:collection].nil?
        opts[:database] ||= nil
        setup_own_silo name, versions, opts
        if opts[:dependents].length != 0
          setup_listeners name, opts[:dependents], opts[:generator], opts[:callback], opts[:session], opts[:database], opts[:collection]
        end
      end



      protected
      def setup_own_silo name, versions, opts
        define_method "#{name}_silo", ->(version=nil) { from_silo(name, version) }

        set_callback :save, :after do
          update_silo name, opts[:generator], versions, opts[:callback], opts[:session], opts[:database], opts[:collection]
        end

        set_callback :destroy, :after do
          destroy_silo name, versions, opts[:callback], opts[:session], opts[:database], opts[:collection]
        end
      end

      def setup_listeners name, dependents, generator, callback, session, database, collection
        registry = dependents.each_with_object([]) do |dep, arr|
          next unless dep[:class_name]
          out = {
            class_name: dep[:class_name], 
            parent_class: self.to_s, 
            silo_name: name.to_s, 
            generator: generator, 
            callback: callback,
            session: session,
            collection: collection
          }
          if dep[:foreign_key]
            out[:foreign_key] = dep[:foreign_key]
          else
            out[:foreign_key] = self.to_s.underscore.singularize + "_id"
          end
          arr << out
        end


        registry.each do |key|
          key[:class_name].classify.constantize.class_eval <<-RUBY, __FILE__, __LINE__+1
            set_callback :save, :after do |doc|
              ident = key[:foreign_key].to_sym
              MongoidSilo::UpdateSiloWorker.perform_async(doc.__send__(ident), "#{key[:parent_class]}", "#{key[:silo_name]}", :save, "#{key[:generator]}", "#{key[:callback]}", "#{key[:session]}", "#{key[:database]}", "#{key[:collection]}")
            end

            set_callback :destroy, :after do |doc|
              ident = key[:foreign_key].to_sym
              MongoidSilo::UpdateSiloWorker.perform_async(doc.__send__(ident), "#{key[:parent_class]}", "#{key[:silo_name]}", :destroy, nil, "#{key[:callback]}", "#{key[:session]}", "#{key[:database]}", "#{key[:collection]}")
            end
          RUBY
        end
      end
    end

    def update_silo name, generator, versions, callback, session, database, collection
      MongoidSilo::UpdateSiloWorker.perform_async(self.id.to_s, self.class.to_s, name, :save, generator, versions, callback, session, database, collection)
    end

    def destroy_silo name, versions, callback, session, database, collection
      MongoidSilo::UpdateSiloWorker.perform_async(self.id.to_s, self.class.to_s, name, :destroy, nil, versions, callback, session, database, collection)
    end

    def from_silo name="default", version=nil
      if @data && @data[name]
        @data[name]
      else
        @data = {}
        @data[name] ||= begin
          silo_query = ::Silo.where(item_class: self.class.to_s, item_id: self.id.to_s, silo_type: name)
          silo_query = silo_query.where(version: version) unless version.nil?
          silo_query.first.data
        rescue Mongoid::Errors::DocumentNotFound
          {}
        end
      end
    end

    def json_from_silo
      MultiJson.encode from_silo
    end
  end
end