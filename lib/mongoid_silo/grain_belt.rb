module MongoidSilo
  class GrainBelt
    attr_accessor :object

    class << self
      attr_accessor :versioned_generators_store

      def versioned_generators
        @versioned_generators_store ||= {}

        if self == GrainBelt
          @versioned_generators_store
        else
          superclass.versioned_generators.merge(@versioned_generators_store)
        end
      end

      def version(*args, &block)
        @versioned_generators_store ||= {}
        args.each do |version|
          @versioned_generators_store[version] = block
        end
      end
    end

    def initialize(object)
      @object = object
    end

    def method_missing(meth, *args)
      object.send(meth, *args)
    end

    def generate
      object.attribute_names.each_with_object({}) do |attribute, out|
        out[attribute] = object.send(attribute) unless ["_type", "_id"].include?(attribute)
      end
    end
  end
end

