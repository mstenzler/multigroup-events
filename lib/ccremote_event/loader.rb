require "ccremote_event/loader/base"
require "ccremote_event/loader/meetup"
require "ccremote_event/loader/facebook"

module CCRemoteEvent
	module Loader
  
    class InvalidLoaderTypeError < StandardError
    	def initialize(type)
    		super "Loader type '#{type}' not a valid. valid types are #{CCRemoteEvent::ApiBuilder::BUILD_TYPES.inspect}"
    	end
    end

    class << self
      # Return a fetcher for given type
      def for(type, client, remote_event_api)
        return  case type.to_sym
                when :meetup
                	Meetup.new(client, remote_event_api)
                when :facebook      
                  Facebook.new(client, remote_event_api)
                else
                	raise InvalidAuthenticatorTypeError(type)
                end
      end
    end
  end
end
