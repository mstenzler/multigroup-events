module CCMeetup
  module Fetcher
    class ApiError < StandardError
      def initialize(error_message, request_url)
        super "Meetup API Error: #{error_message} - API URL: #{request_url}"
      end
    end

    class NoResponseError < StandardError
      def initialize
        super "No Response was returned from the Meetup API."
      end
    end
    
    # == CCMeetup::Fetcher::Base
    # 
    # Base fetcher class that other fetchers 
    # will inherit from.
    class Base
      def initialize(options)
        @type = nil
        if options.has_key?(:authorization)
          @authenticator = options[:authorization]
        end
      end
      
      # Fetch and parse a response
      # based on a set of options.
      # Override this method to ensure
      # neccessary options are passed
      # for the request.
      def fetch(options = {})
        url = build_url(options)
        puts "url = '#{url}"
        
        json = get_response(url)
        data = JSON.parse(json)
#        puts "RAW_DATA: '#{data}'"
        
        # Check to see if the api returned an error
        raise ApiError.new(data['details'],url) if data.has_key?('problem')
        
        collection = CCMeetup::Collection.build(data)
        
        # Format each result in the collection and return it
        collection.map!{|result| format_result(result)}
      end
      
      protected
        # OVERRIDE this method to format a result section
        # as per Result type.
        # Takes a result in a collection and
        # formats it to be put back into the collection.
        def format_result(result)
          result
        end

        def use_ssl?
          (@authenticator && @authenticator.use_ssl?) ? true : false
        end
      
        def build_url(options)
          get_signed = options.delete(:get_signed_url)
          target_id = options.delete(:target_id)
          url_options  = { target_id: target_id }
          options = encode_options(options)
          url = base_url(url_options) + params_for(options)
          auth_opts = get_signed ? { get_signed_url: true } : {}
          @authenticator.authorize_url(url, auth_opts)
        end
      
        def base_url(options)
          "#{http}://api.meetup.com/2/#{@type}"
        end

        def http
          use_ssl? ? "https" : "http"
        end
        
        # Create a query string from an options hash
        def params_for(options)
          params = []
          options.each do |key, value|
            params << "#{key}=#{value}"
          end
          "?#{params.join("&")}"
        end
        
        # Encode a hash of options to be used as request parameters
        def encode_options(options)
          options.each do |key,value|
            options[key] = URI.encode(value.to_s)
          end
        end
        
        def get_response(url)
          Net::HTTP.get_response(URI.parse(url)).body || raise(NoResponseError.new)
        end
    end
  end
end