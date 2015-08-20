require 'net/http'
require 'date'
require 'rubygems'
require 'json'
require 'ccmeetup/config'
require 'ccmeetup/type'
require 'ccmeetup/collection'
require 'ccmeetup/fetcher'
require 'ccmeetup/authenticator'

module CCMeetup
#  FETCH_TYPES = [:topics, :cities, :members, :rsvps, :event, :events, :groups, :comments, :photos]
#  AUTHENTICATION_METHODS = [:api_key, :oauth2]

  # CCMeetup Errors
  class NotConfiguredError < StandardError
    def initialize(msg)
      msg ||= "Missing configuration parameter"
      super "Config Error: #{msg}."
    end
  end

  class ApiError < StandardError
    def initialize(msg)
      super "Api Error: #{msg}."
    end
  end
  
  class InvalidRequestTypeError < StandardError
    def initialize(type)
      super "Fetch type '#{type}' not a valid."
    end
  end
  
  # == CCMeetup::Client
  # 
  # Essentially a simple wrapper to delegate requests to
  # different fetcher classes who are responsible for fetching
  # and parsing their own responses.
  class Client
#    FETCH_TYPES = [:topics, :cities, :members, :rsvps, :event, :events, :groups, :comments, :photos]
#    AUTHENTICATION_METHODS = [:api_key, :oauth2]

 #   attr_reader :api_key, :access_token, :auth_method, :authentication
    attr_reader :authenticator


    
    # Meetup API Key
    # Get one at http://www.meetup.com/meetup_api/key/
    # Needs to be the group organizers API Key
    # to be able to RSVP for other people
    #@@api_key = nil
    #def self.api_key; @@api_key; end;
    #def self.api_key=(key); @@api_key = key; end;
    def initialize(options = {})
      auth_method = options[:auth_method] || :api_key

      if AUTHENTICATION_METHODS.include?(auth_method.to_sym)
        @authenticator = CCMeetup::Authenticator.for(auth_method, options)
      else
        raise NotConfiguredError.new("auth_method must be one of '#{AUTHENTICATION_METHODS}'")
      end
    end
    
    def fetch(type, options = {})      
      # Merge in all the standard options
      # Keeping whatever was passed in
#      options = default_options.merge(options)
      
      if FETCH_TYPES.include?(type.to_sym)
        # Get the custom fetcher used to manage options, api call to get a type of response
        fetcher = CCMeetup::Fetcher.for(type, @authenticator)
        return fetcher.fetch(options)
      else
        raise InvalidRequestTypeError.new(type)
      end
    end
    
    protected
#      def self.default_options
#        {
#          :key => api_key
#        }
#      end
      
      # Raise an error if CCMeetup has not been
      # provided with an api key
#      def self.check_configuration!
#        raise NotConfiguredError.new unless api_key
#      end
  end
end