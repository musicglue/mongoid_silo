require 'active_support/concern'

module Mongoid
  module Silo
    extend ActiveSupport::Concern

    module ClassMethods
      def silo name=:default, opts={}
        opts = if block_given?
          opts = ActiveSupport::OrderedOptions.new
          opts.dependents = []
          opts.callback = nil
          yield(opts)
          opts.generator ||= "MongoidSilo::GrainBelt"
          opts
        else
          opts[:generator] ||= "MongoidSilo::GrainBelt"
          opts[:dependents] = []
          opts[:callback] = nil
          opts
        end
        setup_own_silo name, opts
        if opts[:dependents].length != 0
          setup_listeners name, opts[:dependents], opts[:generator], opts[:callback]
        end
      end



      protected
      def setup_own_silo name, opts
        define_method "#{name}_silo" do
          from_silo name
        end

        set_callback :save, :after do
          update_silo name, opts[:generator], opts[:callback]
        end

        set_callback :destroy, :after do
          destroy_silo name, opts[:callback]
        end
      end

      def setup_listeners name, dependents, generator, callback
        registry = dependents.each_with_object([]) do |dep, arr|
          next unless dep[:class_name]
          out = {class_name: dep[:class_name], parent_class: self.to_s, silo_name: name.to_s, generator: generator, callback: callback}
          if dep[:foreign_key]
            out[:foreign_key] = dep[:foreign_key]
          else
            out[:foreign_key] = self.to_s.underscore.singularize + "_id"
          end
          arr << out
        end


        registry.each do |key|
          key[:class_name].classify.constantize.class_eval <<-EOS, __FILE__, __LINE__+1
            set_callback :save, :after do
              ident = key[:foreign_key].to_sym
              MongoidSilo::UpdateSiloWorker.perform_async(self.__send__(ident), "#{key[:parent_class]}", "#{key[:silo_name]}", :save, "#{key[:generator]}", #{key[:callback]})
            end

            set_callback :destroy, :after do
              ident = key[:foreign_key].to_sym
              MongoidSilo::UpdateSiloWorker.perform_async(self.__send__(ident), "#{key[:parent_class]}", "#{key[:silo_name]}", :destroy, #{key[:callback]})
            end
          EOS
        end
      end
    end

    def update_silo name, generator, callback
      MongoidSilo::UpdateSiloWorker.perform_async(self.id.to_s, self.class.to_s, name, :save, generator, callback)
    end

    def destroy_silo name, callback
      MongoidSilo::UpdateSiloWorker.perform_async(self.id.to_s, self.class.to_s, name, :destroy, callback)
    end

    def from_silo name="default"
      if @bag && @bag[name]
        @bag[name]
      else
        @bag = {}
        @bag[name] ||= begin
          silo = ::Silo.where(item_class: self.class.to_s, item_id: self.id.to_s, silo_type: name).first
          silo.bag
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