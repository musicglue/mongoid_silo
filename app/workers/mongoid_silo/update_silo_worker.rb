require 'sidekiq'

module MongoidSilo

  class UpdateSiloWorker
    include Sidekiq::Worker

    def perform(item_id, item_class, name, mode="save", method=nil)
      @item_id, @item_class = item_id, item_class

      mode.to_s == "save" ? update_silo(name, method) : destroy_silo(name)
    end


    private
    def update_silo name, method
      @item = @item_class.classify.constantize.send(:find, @item_id)
      @silo = Silo.where(item_class: @item_class, item_id: @item_id, silo_type: name).first
      if @silo
        @silo.set(:bag, @item.send(method))
      else
        @silo = Silo.create(item_class: @item_class, item_id: @item_id, bag: @item.send(method), silo_type: name)
      end
    end

    def destroy_silo name
      @silo = Silo.where(item_class: @item_class, item_id: @item_id, silo_type: name).first
      if @silo
        @silo.destroy
      end
    end

  end
    
end