require 'sidekiq'

module MongoidSilo

  class UpdateSiloWorker
    include Sidekiq::Worker

    def perform(item_id, item_class, name, mode="save", generator=nil, versions=nil, callback=nil, session, database, collection)
      @item_id, @item_class, @generator, @versions, @callback = item_id, item_class, generator, versions, callback
      @session, @database, @collection = session, database, collection
      raise ArgumentError if @session.nil? or @collection.nil?
      mode.to_s == "save" ? update_silo(name, generator) : destroy_silo(name)
    end


    private
    def update_silo name, generator
      @item = item_class.find(@item_id)
      # if !@versions.nil?
      #   puts "VERSIONED, oh noes!"
      #   @versions.each do |version|
      #     generate_silo(@item, name, version)
      #   end
      # else
      generate_silo(@item, name)
      # end
      unless @callback.nil? || @callback == ""
        @item.__send__(@callback, :updated)
      end
    end

    def destroy_silo name
      @silo = Silo.with(silo_options).where(item_class: @item_class, item_id: @item_id, silo_type: name).first
      if @silo
        @silo.with(silo_options).destroy
      end
      unless @callback.nil? || @callback == ""
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

    def generate_silo item, name, version=nil
      if version.nil?
        @silo = Silo.with(silo_options).where(item_class: @item_class, item_id: @item_id, silo_type: name).first
        @content = generator_class.send(:new, item).run
      else
        @silo = Silo.with(silo_options).where(item_class: @item_class, item_id: @item_id, silo_type: name, version: version).first
        @content = generator_class.send(:new, item, version).run
      end
      if @silo
        @silo.with(silo_options).set(:data, @content)
      else
        @silo = Silo.with(silo_options).create(item_class: @item_class, item_id: @item_id, data: @content, silo_type: name)
      end
    end

    def silo_options
      out = {}
      out[:session] = (@session || :default)
      out[:collection] = @collection if @collection
      out[:database] = @database if @database
      out.reject!{|k,v| v.nil? || v.blank? }
      out
    end

  end
    
end