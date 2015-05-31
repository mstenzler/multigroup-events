module CCRemoteEvent
  module Builder
    class Base
      attr_accessor :api_client, :remote_event_api

      def initialize(client, options = {})
        @api_client = client
        if options.has_key?(:remote_event_api)
          @remote_event_api = options[:remote_event_api]
        end
      end
 
    end
  end
end