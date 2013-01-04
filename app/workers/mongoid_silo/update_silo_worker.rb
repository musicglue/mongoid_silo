require 'sidekiq'

module MongoidSilo

  class UpdateSiloWorker
    include Sidekiq::Worker

    def perform(item_id, item_class, name, mode="save", silovator=nil)
      @item_id, @item_class, @silovator = item_id, item_class, silovator

      mode.to_s == "save" ? update_silo(name, silovator) : destroy_silo(name)
    end


    private
    def update_silo name, silovator
      @item = item_class.send(:find, @item_id)
      @silo = Silo.where(item_class: @item_class, item_id: @item_id, silo_type: name).first
      @content = silovator_class.send(:new, @item).generate
      if @silo
        @silo.set(:bag, @content)
      else
        @silo = Silo.create(item_class: @item_class, item_id: @item_id, bag: @content, silo_type: name)
      end
    end

    def destroy_silo name
      @silo = Silo.where(item_class: @item_class, item_id: @item_id, silo_type: name).first
      if @silo
        @silo.destroy
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


    def silovator_class
      cl = nil
      @silovator.split("::").inject(nil) do |parent, identifier|
        parent ||= Kernel
        cl = parent.const_get(identifier)
      end
      cl
    end

  end
    
end