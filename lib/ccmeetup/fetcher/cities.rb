module CCMeetup
  module Fetcher
    class Cities < Base
      def initialize(auth)
        super(auth)
        @type = :cities
      end
      
      # Turn the result hash into a City Class
      def format_result(result)
        CCMeetup::Type::City.new(result)
      end
    end
  end
end