require "ccmeetup/authenticator/base"
require "ccmeetup/authenticator/api_key"
#require "ccmeetup/authenticator/api_key_signature"
require "ccmeetup/authenticator/oauth2"

module CCMeetup
	module Authenticator
    AUTHENTICATION_METHODS = [:api_key, :api_key_signature, :oauth2]

    class InvalidAuthenticatorTypeError < StandardError
    	def initialize(type)
    		super "Authenticator type '#{type}' not a valid. valid types are #{AUTHENTICATION_METHODS.inspect}"
    	end
    end

    class << self
      # Return a fetcher for given type
      def for(type, options={})
        return  case type.to_sym
                when :api_key
                	ApiKey.new(options)
                when :api_key_signature      
                  ApiKeySignature.new(options)
                when :oauth2
                	Oauth2.new(options)
                else
                	raise InvalidAuthenticatorTypeError(type)
                end
      end
    end
  end
end

=begin
  class Authenticator
  	AUTHENTICATION_METHODS = [:api_key, :api_key_signature, :oauth2]

    attr_reader :api_key, :access_token, :auth_method, :authentication

    def initialize(options = {})
      @auth_method = options[:auth_method] || :api_key
      case @auth_method
      when :api_key, :api_key_signature
        @api_key = options[:api_key] 
        raise NotConfiguredError.new("Client.new missing 'api_key' parameter") unless @api_key
      when :oauth2
        @authentication = options[:authentication]
        raise NotConfiguredError.new("Client.new missing 'authentication' parameter") unless @authentication
        unless @authentication.respond_to? :access_token
          raise NotConfiguredError.new("authentication object does not have an access_token method")
        end
      else
        raise NotConfiguredError.new("auth_method must be one of '#{AUTHENTICATION_METHODS}'")
      end
    end
  end
end
=end
