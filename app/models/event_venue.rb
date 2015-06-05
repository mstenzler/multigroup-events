class EventVenue < ActiveRecord::Base
  has_many :remote_event_api_sources
  has_many :events

  def self.create_event_venue(args)
    unless (args)
      raise "Must supply a hash or arguments to #{self.class.name}.#{__method__}"
    end
    unless (args.is_a? Hash)
      raise "first argument must be a hash in #{self.class.name}.#{__method__}"
    end
    geo_area = nil
    zip = args['zip']
    country_code = args['country_code']
    country = args['country']
    country_code ||= country

    if (zip && country_code)
      if (geo_country = GeoCountry.where(country_code: args.country.upcase))
        geo_area = GeoArea.get_or_create_geo_area(geo_country, zip)
      end
    end

    create! do |event_venue|
      event_venue.geo_area_id = geo_area.id if geo_area
      event_venue.remote_source = args[:remote_source]
      event_venue.remote_id = args[:remote_id]
      event_venue.zip = args[:zip]
      event_venue.phone = args[:phone] if args["phone"]
      event_venue.lon = args[:lon]
      event_venue.lat = args[:lat]
      event_venue.name = args[:name]
      event_venue.state = args[:state]
      event_venue.city = args[:city]
      event_venue.country = args[:country]
      event_venue.address_1 = args[:address_1]
      event_venue.address_2 = args[:address_2] if args[:address_2] 
      event_venue.address_3 = args[:address_3] if args[:address_3]
    end
  end

  def self.find_or_create_for_meetup(venue_obj)
    unless(venue_obj)
      raise "Venue Object must be passed into #{self.class.name}.#{__method__}"
    end
    l_source_id = venue_obj.id
    unless (l_source_id)
      raise "Venue Object does not contain an id value in #{self.class.name}.#{__method__}"
    end
    venue = self.where(remote_source: RemoteEvent::MEETUP_NAME,
                       remote_id: l_source_id).first
    unless (venue)
      params = { remote_source: RemoteEvent::MEETUP_NAME,
                 remote_id: l_source_id,
                 zip: venue_obj.zip,
                 phone: venue_obj.phone,
                 lon: venue_obj.lon,
                 lat: venue_obj.lat,
                 name: venue_obj.name,
                 state: venue_obj.state,
                 city: venue_obj.city,
                 country: venue_obj.country,
                 address_1: venue_obj.address_1,
               }
      params['address_2'] = venue_obj.address_2 if venue_obj.address_2
      params['address_3'] = venue_obj.address_3 if venue_obj.address_3
      venue = self.create_event_venue(params)
    end
    venue
  end

  def location(args={})
    ret = "#{address_1}</br>"
    ret += "#{address_2}</br>" if address_2
    ret += "#{address_3}</br>" if address_3
    ret += "#{city}, #{state} #{zip}"
    if (args[:include_country] && country)
      ret += " #{country}"
    end
    ret.html_safe
  end

end

