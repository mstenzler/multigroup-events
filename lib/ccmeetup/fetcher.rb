require 'ccmeetup/fetcher/base'
CCMeetup::FETCH_TYPES.each do |fetch_type|
  require "ccmeetup/fetcher/#{fetch_type}"
end

module CCMeetup
  module Fetcher
    
    class << self
      # Return a fetcher for given type
      def for(type, auth)
        if CCMeetup::FETCH_TYPES.include?(type.to_sym)
          fetcher_name = "CCMeetup::Fetcher::#{type.to_s.camelize}"
          puts "fetcher_name = #{fetcher_name}"
          return fetcher_name.constantize.new( { authorization: auth })
        else
          raise ArgumentError, "type: #{type} is not a valid fetch type"
        end
      end 
    end
  end
end