module CCRemoteEvent
  module Builder
    class Base
      attr_accessor :api_client

      def initialize(client)
        @api_client = client
      end
 
    end
  end
end