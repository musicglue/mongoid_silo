require 'sidekiq'

module MongoidSilo
  refine String do
    def constantize
      Object.module_eval(":#{foo}", __FILE__, __LINE__)
    end
  end

  class UpdateSiloWorker
    include Sidekiq::Worker

    def perform(item_id, item_class, name, mode="save", generator=nil, callback=nil)
      @item_class = item_class.constantize
      @generator  = generator ? generator.constantize : nil
      @callback   = callback
      @item_id    = item_id.kind_of?(String) ? item_id : item_id["$oid"]

      mode.to_s == "save" ? update_silo(name, generator) : destroy_silo(name)
    end

    private

    def update_silo name, generator
      @item = @item_class.send(:find, @item_id)
      @silo = Silo.where(item_class: @item_class, item_id: @item_id, silo_type: name).first
      @content = @generator.send(:new, @item).generate

      if @silo
        @silo.set(:bag, @content)
      else
        @silo = Silo.create(item_class: @item_class, item_id: @item_id, bag: @content, silo_type: name)
      end

      unless @callback.nil? || @callback == ""
        @item.__send__(@callback, :updated)
      end
    end

    def destroy_silo name
      @silo = Silo.where(item_class: @item_class, item_id: @item_id, silo_type: name).first

      if @silo
        @silo.destroy
      end

      unless @callback.nil? || @callback == ""
        @item.__send__(@callback, :destroyed)
      end
    end
  end
end
