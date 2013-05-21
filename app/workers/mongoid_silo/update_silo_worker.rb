require 'sidekiq'

module MongoidSilo
  refine String do
    def constantize
      Object.module_eval("::#{foo}", __FILE__, __LINE__)
    end
  end

  class UpdateSiloWorker
    include Sidekiq::Worker

    attr_reader :generator, :klass, :id, :name, :callback

    def perform(id, klass, name, mode = :save, generator = nil, callback = nil)
      @id        = id.kind_of?(String) ? id : id["$oid"]
      @klass     = klass.constantize
      @generator = generator ? generator.constantize : nil
      @callback  = callback
      @name      = name

      __send__(mode.to_sym)
    end

    private

    def save
      content = generator.send(:new, item).generate

      if silo = Silo.where(item_class: klass, item_id: id, silo_type: name).first
        silo.set(:bag, content)
      else
        silo = Silo.create(item_class: klass, item_id: id, bag: content, silo_type: name)
      end

      call_callback(:updated)
    end

    def destroy
      if silo = Silo.where(item_class: klass, item_id: id, silo_type: name).first
        silo.destroy
      end

      call_callback(:destroyed)
    end

    def call_callback(event)
      if !callback.to_s.empty?
        item.__send__(callback, :destroyed)
      end
    end

    def item
      @item ||= klass.send(:find, id)
    end
  end
end

