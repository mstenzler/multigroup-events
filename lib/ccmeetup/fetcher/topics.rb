module CCMeetup
  module Fetcher
    class Topics < Base
      def initialize(auth)
        super(auth)
        @type = :topics
      end
      
      # Turn the result hash into a Topic Class
      def format_result(result)
        CCMeetup::Type::Topic.new(result)
      end
    end
  end
end