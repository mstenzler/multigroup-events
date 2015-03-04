module CCMeetup
  module Fetcher
    class Members < Base
      def initialize(auth)
        super(auth)
        @type = :members
      end
      
      # Turn the result hash into a Member Class
      def format_result(result)
        CCMeetup::Type::Member.new(result)
      end
    end
  end
end