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

  REMOTE_EVENT_API_URL_TYPES = ["event", "rsvp"]
  EVENT_API_URL_TYPE = REMOTE_EVENT_API_URL_TYPES[0]
  RSVP_API_URL_TYPE = REMOTE_EVENT_API_URL_TYPES[1]


  REMOTE_SOURCES = [ { name: 'meetup', uri_host: 'api.meetup.com' }, 
                     { name: 'facebook', uri_host: 'api.facebook.com' }]
  MEETUP_NAME = REMOTE_SOURCES[0][:name]
  MEETUP_URI_HOST = REMOTE_SOURCES[0][:uri_host]
  FACEBOOK_NAME = REMOTE_SOURCES[1][:name]
  FACEBOOK_URI_HOST = REMOTE_SOURCES[1][:uri_host]

  REMOTE_SOURCE_HOST_MAP = { 
    MEETUP_URI_HOST => MEETUP_NAME,
    FACEBOOK_URI_HOST => FACEBOOK_NAME
  } 

  has_one :remote_event_api, :dependent => :destroy, inverse_of: :remote_event
  accepts_nested_attributes_for :remote_event_api, allow_destroy: true, update_only: true
#  has_many :remote_event_api_details

 # before_validation :populate_remote_event_api, on: :create
 #  before_save  :populate_remote_event_api

#  validates :remote_event_api, presence: true
  validates_associated :remote_event_api
 # validate :must_have_linked_events
#  validate :must_have_remote_api_key

  def self.determine_url_source(url)
    uri = URI(url)
    hostname = uri.host
    ret = nil
    if hostname && REMOTE_SOURCE_HOST_MAP.has_key?(hostname)
      ret = REMOTE_SOURCE_HOST_MAP[hostname]
    end
    ret
  end

  private

    def must_have_linked_events
      errors.add(:base, 'Must have at least one linked event') if linked_events.all?(&:marked_for_destruction?)
    end

    def must_have_remote_api_key
      has_key = remote_event_api.api_key.empty? ? false : true
      unless (has_key) 
        errors.add(:base, 'Must have an api key')
      end
    end

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
      logger.debug("primary_event =")
      logger.debug(primary_event)
      primary_start_date = api.remote_event_api_details[primary_event_index].start_date
      #logger.debug("primary_start_date = " + primary_start_date)
      if (primary_start_date)
        logger.debug("!! Setting start date!!!")
        self.start_date = primary_start_date
      end
      if (primary_end_date = api.remote_event_api_details[primary_event_index].end_date)
        self.end_date = primary_end_date
      end
      self.remote_event_api = api
    end

end
