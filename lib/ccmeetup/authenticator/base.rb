require 'uri'
require 'cgi'

module CCMeetup
  module Authenticator
	  class NotConfiguredError < StandardError
	    def initialize(msg)
	      msg ||= "Missing configuration parameter"
	      super "Config Error: #{msg}."
	    end
	  end

    # == CCMeetup::Authenticator::Base
    # 
    # Base fetcher class that other fetchers 
    # will inherit from.
    class Base
      def initialize
        raise NotConfiguredError("Must instantiate a sublcass of CCMeetup::Authenticator::Base ")
      end
      
      def authorize_url
      	raise NotConfiguredError("Must implement base_url in a sublcass of CCMeetup::Authenticator::Base")
      end

      def use_ssl?
        false
      end
      
      protected

        def add_to_query_string(url, items = {})
        	uri = URI.parse(URI.encode(url))
        	hquery = uri.query ? CGI::parse(uri.query) : {}
        	components = Hash[uri.component.map { |key| [key, uri.send(key)] }]
        	new_hquery = hquery.merge(items)
        	new_query = URI.encode_www_form(new_hquery)
        	new_components = components.merge(query: new_query)
        	new_uri = URI::Generic.build(new_components)
        	URI.decode(new_uri.to_s)
        end

    end
  end
end