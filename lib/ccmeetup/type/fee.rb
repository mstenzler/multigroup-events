module CCMeetup
  module Type
    
    # == CCMeetup::Type::Fee
    #
    # Data wraper for a Fee fetching response
    # Used to access result attributes as well
    # as progammatically fetch relative data types
    # based on this city.
        
    class Fee
      
      attr_accessor :fee
      
      def initialize(fee = {})
        self.fee = fee
      end
      
      def method_missing(id, *args)
        return self.fee[id.id2name]
      end
      
      # Special accessors that need typecasting or other parsing
      def amount
        return self.fee['amount'].to_f
      end

      def required
        return (self.fee['required'] == 1 ? true : false)
      end
    end
  end
end