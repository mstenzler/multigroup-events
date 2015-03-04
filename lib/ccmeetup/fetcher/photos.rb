module CCMeetup
  module Fetcher
    class Photos < Base
      def initialize(auth)
        super(auth)
        @type = :photos
      end
      
      # Turn the result hash into a Photo Class
      def format_result(result)
        CCMeetup::Type::Photo.new(result)
      end
    end
  end
end