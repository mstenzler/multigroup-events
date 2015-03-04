module CCMeetup
  module Fetcher
    class Event < Base
      def initialize(auth)
        super(auth)
        @type = :event
      end

      def base_url(options)
        unless (target_id = options[:target_id])
          raise ArgumentError, "Event.base_url requires a :target_id option"
        end
        "#{http}://api.meetup.com/2/#{@type}/#{target_id}"
      end
    
      # Turn the result hash into a Event Class
      def format_result(result)
        CCMeetup::Type::Event.new(result)
      end
    end
  end
end