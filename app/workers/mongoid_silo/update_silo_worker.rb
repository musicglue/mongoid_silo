require 'sidekiq'

module MongoidSilo

  class UpdateSiloWorker
    include Sidekiq::Worker

    def perform(item_id, item_class, name, mode="save", generator=nil, callback=nil)
      @item_id, @item_class, @generator, @callback = item_id, item_class, generator, callback
      mode.to_s == "save" ? update_silo(name, generator) : destroy_silo(name)
    end


    private
    def update_silo name, generator
      @item = item_class.send(:find, @item_id)
      @silo = Silo.where(item_class: @item_class, item_id: @item_id, silo_type: name).first
      @content = generator_class.send(:new, @item).generate
      if @silo
        @silo.set(:bag, @content)
      else
        @silo = Silo.create(item_class: @item_class, item_id: @item_id, bag: @content, silo_type: name)
      end
      if @callback
        @item.__send__(@callback, :updated)
      end
    end

    def destroy_silo name
      @silo = Silo.where(item_class: @item_class, item_id: @item_id, silo_type: name).first
      if @silo
        @silo.destroy
      end
      if @callback
        @item.__send__(@callback, :destroyed)
      end
    end

    def item_class
      cl = nil
      @item_class.split("::").inject(nil) do |parent, identifier|
        parent ||= Kernel
        cl = parent.const_get(identifier)
      end
      cl
    end


    def generator_class
      cl = nil
      @generator.split("::").inject(nil) do |parent, identifier|
        parent ||= Kernel
        cl = parent.const_get(identifier)
      end
      cl
    end

  end
    
end