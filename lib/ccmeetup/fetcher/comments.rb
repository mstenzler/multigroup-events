module CCMeetup
  module Fetcher
    class Comments < Base
      def initialize(auth)
        super(auth)
        @type = :comments
      end
      
      # Turn the result hash into a Comment Class
      def format_result(result)
        CCMeetup::Type::Comment.new(result)
      end
    end
  end
end