module CCMeetup
  module Type
    
    # == CCMeetup::Type::Venue
    #
    # Data wraper for a Venue fetching response
    # Used to access result attributes as well
    # as progammatically fetch relative data types
    # based on this city.
    
    # See http://www.meetup.com/meetup_api/docs/venues/ for available fields
    
    class Venue
      
      attr_accessor :venue
      
      def initialize(venue = {})
        self.venue = venue
      end
      
      def method_missing(id, *args)
        return self.venue[id.id2name]
      end
      
      # Special accessors that need typecasting or other parsing
      def id
        return self.venue['id'].to_i
      end

      def lat
        return self.venue['lat'].to_f
      end

      def lon
        return self.venue['lon'].to_f
      end
    end
  end
end