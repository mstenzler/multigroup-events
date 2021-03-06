#require "venue"
#require "fee"

module CCMeetup
  module Type
    
    # == CCMeetup::Type::Event
    #
    # Data wraper for a Event fethcing response
    # Used to access result attributes as well
    # as progammatically fetch relative data types
    # based on this event.
    
    # Edited by Jason Berlinsky on 1/20/11 to allow for arbitrary data access
    # See http://www.meetup.com/meetup_api/docs/events/ for available fields
    
    class Event
      
      attr_accessor :event, :venue, :fee
      
      def initialize(event = {})
        self.event = event
        if (loc_venue = event['venue'])
          self.venue = Venue.new(loc_venue)
        end
        if (loc_fee = event['fee'])
          self.fee = Fee.new(loc_fee)
        end

      end
      
      def method_missing(id, *args)
        return self.event[id.id2name]
      end
      
      # Special accessors that need typecasting or other parsing
      def id
        self.event['id'].to_i
      end
      def lat
        self.event['lat'].to_f
      end
      def lon
        self.event['lon'].to_f
      end
#      def yes_rsvp_count
#        self.event['yes_rsvp_count'].to_i
#      end
      def announced_at
        self.event['announced_at'] ? Time.at(self.event['announced_at'] / 1000).to_datetime : nil
      end
      def updated
        #DateTime.parse(self.event['updated'])
        Time.at(self.event['updated'] / 1000).to_datetime
      end
      def time
        #DateTime.parse(self.event['time'])
        ltime = self.event['time']
        puts "Original time = #{ltime}"
#        offset = self.event['utc_offset'] || 0
#        ltime += offset
#        puts "Time + offset (#{offset}) = #{ltime}"
        Time.at( ltime / 1000).to_datetime
      end
    end
  end
end