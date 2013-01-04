require 'active_support/concern'

module Mongoid
  module Silo
    extend ActiveSupport::Concern

    module ClassMethods
      def silo name=:default, opts={}
        opts[:generator] ||= "MongoidSilo::GrainBelt"
        define_method "#{name}_silo" do
          from_silo name
        end

        set_callback :save, :after do
          update_silo name, opts[:generator]
        end

        set_callback :destroy, :after do
          destroy_silo name
        end
      end
    end

    def update_silo name, generator
      MongoidSilo::UpdateSiloWorker.perform_async(self.id.to_s, self.class.to_s, name, :save, generator)
    end

    def destroy_silo name
      MongoidSilo::UpdateSiloWorker.perform_async(self.id.to_s, self.class.to_s, name, :destroy)
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