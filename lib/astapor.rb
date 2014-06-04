require "astapor/version"
require 'logger'

module Astapor
    class SerfHandler
        def initialize
            @name = ENV['SERF_SELF_NAME']
            @role = ENV['SERF_TAG_ROLE'] || ENV['SERF_SELF_ROLE']
            @logger = Logger.new(STDOUT)
            @logger.formatter = proc do |severity, datetime, progname, msg|
                "#{self.class.name}: #{datetime}: #{severity}: #{msg}\n"
            end
            
            if ENV['SERF_EVENT'] == 'user':
                @event = ENV['SERF_USER_EVENT']
            else
                @event = ENV['SERF_EVENT'].gsub! '-', '_'
            end

            @payload = ARGF.read
        end
    end

    class SerfHandlerProxy < SerfHandler
        def initialize
            super()
            @handlers = Hash.new
        end

        def register(role, handler)
            @handlers[role] = handler
        end

        def get_klass
            klass = nil
            if @handlers.has_key?(@role)
                klass = @handlers[@role]
            elsif @handlers.has_key?('default')
                klass = @handlers['default']
            end

            klass
        end

        def run
            klass = get_klass
            if klass.nil? 
                @logger.info("no handler for role #{@role}")
            else
                begin
                    method_object = klass.method(@event.to_sym) 
                    method_object.call
                rescue NameError => e
                    @logger.error("event #{@event} not implemented by class")
                end
            end
        end
    end
end
