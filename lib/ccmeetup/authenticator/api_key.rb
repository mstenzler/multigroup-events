module CCMeetup
  module Authenticator	

    # == CCMeetup::Authenticator::ApiKey
    # 
    # Implements Authentication scheme for the Meetup API using an api_key
    # 
    class ApiKey < Base

      attr_reader :api_key
      
      def initialize(options = {})
      	@api_key = options[:api_key]
        raise CCMeetup::NotConfiguredError.new("Must pass in api_key parameter to CCMeetup::Authenticator::ApiKey.new") unless @api_key
      end
      
      #Add key=api_key to query string to authorize the request for the api_key
      def authorize_url(uri, options = {})
        opts = { key: @api_key }
        if options[:get_signed_url]
          opts.merge!( { sign: "true"})
        end
      	add_to_query_string(uri, opts)
      end
      
    end
  end
end