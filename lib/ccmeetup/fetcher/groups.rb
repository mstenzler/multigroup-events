module CCMeetup
  module Fetcher
    class Groups < Base
      def initialize(auth)
        super(auth)
        @type = :groups
      end
      
      # Turn the result hash into a Group Class
      def format_result(result)
        CCMeetup::Type::Group.new(result)
      end
    end
  end
end