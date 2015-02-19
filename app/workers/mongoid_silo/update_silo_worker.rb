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
      return if id.nil?
      @id        = id.kind_of?(String) ? id : id["$oid"]
      @klass     = klass.constantize
      @generator = generator ? generator.constantize : nil
      @callback  = callback
      @name      = name

      Sidekiq::Logging.with_context("#{@klass} #{@id} #{@generator}") do
        begin
          start = Time.now
          logger.info { "#{mode} start" }
          __send__(mode.to_sym)
          logger.info { "#{mode} done: #{elapsed(start)} sec" }
        rescue Exception
          logger.info { "#{mode} fail: #{elapsed(start)} sec" }
          raise
        end
      end
    end

    private

    def elapsed(start)
      (Time.now - start).to_f.round(3)
    end

    def logger
      Sidekiq.logger
    end

    def save
      if generator.versioned_generators.empty?
        save_unversioned_silo
      else
        save_versioned_silo
      end

      call_callback(:updated)
    end

    def save_unversioned_silo
      content = generator.send(:new, item).generate

      save_silo_content(content, version: 1)
    end

    def save_versioned_silo
      generator.versioned_generators.each do |version, p|
        content = generator.send(:new, item).instance_eval(&p)
        save_silo_content(content, version: version)
      end
    end

    def save_silo_content(content, version: 1)
      if silo = Silo.where(item_class: klass, item_id: id, silo_type: name, version: version).first
        silo.set(bag: content)
      else
        silo = Silo.create(item_class: klass, item_id: id, bag: content, silo_type: name, version: version)
      end
    end

    def destroy
      if silo = Silo.where(item_class: klass, item_id: id, silo_type: name).all
        silo.map(&:destroy)
      end

      call_callback(:destroyed)
    end

    def call_callback(event)
      if !callback.to_s.empty?
        item.__send__(callback, :destroyed)
      end
    end

    def item
      @item ||= klass.find(id) || raise(Mongoid::Errors::DocumentNotFound.new(klass, id))
    end
  end
end
