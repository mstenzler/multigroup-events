require 'ccremote_event/builder'

module CCRemoteEvent

  class NotConfiguredError < StandardError
    def initialize(msg)
      msg ||= "Missing configuration parameter"
      super "Config Error: #{msg}."
    end
  end
  
  class InvalidRequestTypeError < StandardError
    def initialize(type)
      super "Build type '#{type}' not a valid."
    end
  end

  class ApiBuilder

    BUILD_TYPES = [:meetup, :facebook]

    attr_accessor :url_list, :api_client

    def initialize(api_client=nil, urls=nil)
      if (!api_client.nil?)
        @api_client = api_client
      end
      if (urls.nil?)
        return
      elsif (urls.class == Array)
        @url_list = urls
      elsif (urls.class == String)
        @url_list = [urls]
      else
        raise ArgumentError, "#{self.class.name} takes a list of urls on creation"
      end
    end

    def build(type, options = {})
      options = { url_list: url_list}.merge(options)
      client = options.delete(:api_client) || api_client
#      check_is_initialized
      if BUILD_TYPES.include?(type.to_sym)
        # Get the custom builder used to build the event_api_urls
 #       builder = RemoteEventApiBuilder::Builder.for(type, client)
        builder = CCRemoteEvent::Builder.for(type, client)
        return builder.build(options)
      else
        raise InvalidRequestTypeError.new(type)
      end
    end

    def check_is_initialized
      unless (url_list && api_client)
        raise NotConfiguredError.new("url_list and api_client must both be set in #{self.class.name}")
      end
    end

  end
end