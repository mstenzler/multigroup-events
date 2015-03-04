module CCMeetup
  module Fetcher
    class Rsvps < Base
      def initialize(auth)
        super(auth)
        @type = :rsvps
      end
      
      # Turn the result hash into a Rsvp Class
      def format_result(result)
        CCMeetup::Type::Rsvp.new(result)
      end
    end
  end
end