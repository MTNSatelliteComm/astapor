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
            @tags = Hash.new

            # collect all tags
            ENV.each do |key, tag|
                if key.start_with('SERF_TAG_')
                    @tags[key.sub(/^SERF_TAG_/, '').downcase] = tag.downcase
                end
            end
            
            if ENV['SERF_EVENT'] == 'user'
                @event = ENV['SERF_USER_EVENT'].gsub '-', '_'
            elsif ENV['SERF_EVENT'] == 'query'
                @event = ENV['SERF_QUERY_NAME'].gsub '-', '_'
            else                
                @event = ENV['SERF_EVENT'].gsub '-', '_'
            end
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
                    @logger.info("event #{@event} not implemented by #{klass.class.name} class")
                end
            end
        end
    end
end
