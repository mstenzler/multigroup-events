require "ccremote_event/builder/base"
require "ccremote_event/builder/meetup"
require "ccremote_event/builder/facebook"

module CCRemoteEvent
	module Builder
  
    class InvalidBuilderTypeError < StandardError
    	def initialize(type)
    		super "Builder type '#{type}' not a valid. valid types are #{CCRemoteEvent::ApiBuilder::BUILD_TYPES.inspect}"
    	end
    end

    class << self
      # Return a fetcher for given type
      def for(type, client)
        return  case type.to_sym
                when :meetup
                	Meetup.new(client)
                when :facebook      
                  Facebook.new(client)
                else
                	raise InvalidAuthenticatorTypeError(type)
                end
      end
    end
  end
end
