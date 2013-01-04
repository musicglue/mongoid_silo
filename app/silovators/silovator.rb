module MongoidSilo
  class Silovator

    attr_accessor :object
    
    def initialize(object)
      @object = object
    end

    def method_missing(meth, *args)
      object.send(meth)
    end

    def generate
      out = {}
      object.attribute_names.each do |attribute|
        out[attribute] = object.send(attribute) unless ["_type", "_id"].include?(attribute)
      end
      out
    end
  end
end