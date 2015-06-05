require 'ccremote_event/builder'
require 'ccremote_event/loader'

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
    MEETUP_SOURCE = BUILD_TYPES[0].to_s
    FACEBOOK_SOURCE = BUILD_TYPES[1].to_s

    attr_accessor :url_list, :event_id_list, :api_client, :remote_event_api

 #   def initialize(api_client=nil, urls=nil)
    def initialize(args = {})
      api_client = args[:api_client]
      urls = args[:urls]
      event_ids = args[:event_ids]
      remote_event_api = args[:remote_event_api]
      if (!api_client.nil?)
        @api_client = api_client
      end
      if (!remote_event_api.nil?)
        @remote_event_api = remote_event_api
      end
      if (!urls.nil?)
        if (urls.class == Array)
          @url_list = urls
        elsif (urls.class == String)
          @url_list = [urls]
        else
          raise ArgumentError, "#{self.class.name} takes a list of urls on creation"
        end
      end
      if (!event_ids.nil?)
        if (event_ids.class == Array)
          @event_id_list = event_ids
        elsif (event_ids.class == String)
          @event_id_list = [urls]
        else
          raise ArgumentError, "#{self.class.name} takes a list of event_ids on creation"
        end
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

    def load(type, options = {})
      options = { url_list: url_list, event_id_list: event_id_list}.merge(options)
      client = options.delete(:api_client) || api_client
      re_api = options.delete(:remote_event_api) || remote_event_api
#      check_is_initialized
      if BUILD_TYPES.include?(type.to_sym)
        # Get the custom builder used to build the event_api_urls
 #       builder = RemoteEventApiBuilder::Builder.for(type, client)
 #       builder = CCRemoteEvent::Builder.for(type, client)
        loader = CCRemoteEvent::Loader.for(type, client, re_api)
        return loader.load(options)
      else
        raise InvalidRequestTypeError.new(type)
      end
    end

    def check_is_initialized
      unless ((url_list || event_id_list) && api_client)
        raise NotConfiguredError.new("url_list or event_id_list and api_client must both be set in #{self.class.name}")
      end
    end

  end
end