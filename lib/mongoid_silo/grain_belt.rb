module MongoidSilo
  class GrainBelt

    attr_accessor :object
    
    def initialize(object, version=nil)
      @object = object
      @version = version
      @genmeth = "generate"
    end

    def method_missing(meth, *args)
      object.send(meth)
    end

    def run
      self.__send__(@genmeth)
    end

    def generate
      object.attribute_names.each_with_object({}) do |attribute, out|
        out[attribute] = object.send(attribute) unless ["_type", "_id"].include?(attribute)
      end
    end
    
  end
end