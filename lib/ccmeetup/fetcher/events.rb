module CCMeetup
  module Fetcher
    class Events < Base
      def initialize(auth)
        super(auth)
        @type = :events
      end
      
      # Turn the result hash into a Event Class
      def format_result(result)
        CCMeetup::Type::Event.new(result)
      end
    end
  end
end