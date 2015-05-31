module CCRemoteEvent
  module Loader
    class Base
      attr_accessor :api_client, :remote_event_api

      def initialize(client, remote_api)
        @api_client = client
        @remote_event_api = remote_api
      end
 
    end
  end
end