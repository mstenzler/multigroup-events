class RemoteEvent < Event
  require 'uri'
  require 'ccmeetup'
  require 'ccremote_event'

  def self.sti_base_class
    Event
  end

  include FriendlyTitleHelper
  include SetModelNameHelper

#  attr_accessor :remote_api_key, :remember_api_key
  attr_accessor :excluded_guests, :excluded_users 

  REMOTE_EVENT_API_URL_TYPES = ["event", "rsvp"]
  EVENT_API_URL_TYPE = REMOTE_EVENT_API_URL_TYPES[0]
  RSVP_API_URL_TYPE = REMOTE_EVENT_API_URL_TYPES[1]


#  REMOTE_SOURCES = [ { name: 'meetup', uri_host: 'api.meetup.com' }, 
#                     { name: 'facebook', uri_host: 'api.facebook.com' }]
#  REMOTE_SOURCES = CONFIG[:remote_api_sources]
#  MEETUP_NAME = REMOTE_SOURCES[0][:name]
#  MEETUP_URI_HOST = REMOTE_SOURCES[0][:uri_host]
#  FACEBOOK_NAME = REMOTE_SOURCES[1][:name]
#  FACEBOOK_URI_HOST = REMOTE_SOURCES[1][:uri_host]

  REMOTE_SOURCES = CONFIG[:remote_api_sources]
#  logger.debug("remote_sorces =#{REMOTE_SOURCES.inspect}" )
  MEETUP_NAME = REMOTE_SOURCES['meetup']['name']
  MEETUP_URI_HOST = REMOTE_SOURCES['meetup']['uri_host']
  FACEBOOK_NAME = REMOTE_SOURCES['facebook']['name']
  FACEBOOK_URI_HOST = REMOTE_SOURCES['facebook']['uri_host']

  REMOTE_SOURCE_HOST_MAP = { 
    MEETUP_URI_HOST => MEETUP_NAME,
    FACEBOOK_URI_HOST => FACEBOOK_NAME
  } 

  has_one :remote_event_api, :dependent => :destroy, inverse_of: :remote_event
  accepts_nested_attributes_for :remote_event_api, allow_destroy: true, update_only: true

  has_many :excluded_remote_members, foreign_key: :event_id, dependent: :destroy, inverse_of: :remote_event
  accepts_nested_attributes_for :excluded_remote_members, allow_destroy: true, update_only: true


  before_save :init_and_load_remote_event_api
  after_initialize :populate_excluded_members

  validates_associated :remote_event_api

  def self.determine_url_source(url)
    uri = URI(url)
    hostname = uri.host
    ret = nil
    if hostname && REMOTE_SOURCE_HOST_MAP.has_key?(hostname)
      ret = REMOTE_SOURCE_HOST_MAP[hostname]
    end
    ret
  end

  def excluded_guests_member_ids
    (excluded_guests && excluded_guests.size > 0) ? 
      excluded_guests.map { |eg| eg.remote_member.remote_member_id } :
      []
  end

  def excluded_guests_as_string
    ids = excluded_guests_member_ids
    ids.size > 0 ? ids.map { |id| id.to_s }.join(',') : ""
  end

  def excluded_users_member_ids
     (excluded_users && excluded_users.size > 0) ? 
      excluded_users.map { |eu| eu.remote_member.remote_member_id } :
      []   
  end

  def excluded_users_as_string
    ids = excluded_users_member_ids
    ids.size > 0 ? ids.map { |id| id.to_s }.join(',') : ""
  end

  private

    def populate_excluded_members
      p "** in populate_excluded_members"
      guests = []
      users = []
      if (excluded_remote_members && excluded_remote_members.size > 0)
        logger.debug "Got excluded_remote_members "
        excluded_remote_members.each do |erm|
          curr_type = erm.exclude_type
          logger.debug "Current type = #{curr_type}"
          case curr_type
          when ExcludedRemoteMember::EXCLUDE_GUESTS_TYPE
            logger.debug "Adding to guests erm: #{erm.inspect}"
            guests << erm
          when ExcludedRemoteMember::EXCLUDE_USER_TYPE
            logger.debug "Adding to user erm: #{erm.inspect}"
            users << erm
          else
            logger.error "Got invalid type #{curr_type}"
          end
        end
      end
      p "number of guests = #{guests.size}, num user = #{users.size}"
      self.excluded_guests = (guests.size > 0) ? guests : nil
      self.excluded_users = (users.size > 0) ? users : nil
    end

    def must_have_linked_events
      errors.add(:base, 'Must have at least one linked event') if linked_events.all?(&:marked_for_destruction?)
    end

    def must_have_remote_api_key
      has_key = remote_event_api.api_key.empty? ? false : true
      unless (has_key) 
        errors.add(:base, 'Must have an api key')
      end
    end

    def init_and_load_remote_event_api
      remote_event_api.init_and_load_api()
    end

=begin
    def populate_remote_event_api
      logger.debug("****IN populate_remote_event_api. current remote_event_api=")
      logger.debug(remote_event_api)
      re_api = remote_event_api || RemoteEventApi.new
  #    re_api.remote_event_id = self.id
  #    if remember_api_key == 1
  #      re_api.api_key = remote_api_key
  #    end
      event_urls = []
      linked_events.map { |e| event_urls << e.url  }

      rclient = CCMeetup::Client.new({ auth_method: :api_key, api_key: remote_event_api.api_key })
      re = CCRemoteEvent::ApiBuilder.new(rclient)
      api = re.build(:meetup, { get_signed_url: true, url_list: event_urls, remember_api_key: remote_event_api.remember_api_key })
      primary_event_index = api.primary_remote_event_index
      primary_event = api.remote_event_api_details[primary_event_index]
      logger.debug("+=+=+=+=primary_event =")
      logger.debug(primary_event)
      if (primary_start_date = primary_event.start_date)
        logger.debug("!! Setting start date!!! #{primary_start_date.inspect}")
        self.start_date = primary_start_date
      end
      if (primary_end_date = primary_event.end_date)
        logger.debug("!! Setting end date!!! #{primary_end_date.inspect}")
        self.end_date = primary_end_date
      end
      if (primary_timezone = primary_event.primary_timezone)
        logger.debug("!! Setting timezone!!! #{primary_timezone.inspect}")
        self.timezone = primary_timezone
      end
      if (primary_utc_offset = primary_event.utc_offset)
        logger.debug("!! Setting utc_offset!!! #{primary_utc_offset.inspect}")
        self.utc_offset = primary_utc_offset
      end
      logger.debug("**** END OF populate_remote_event_api.")
      self.remote_event_api = api
    end
=end

end
