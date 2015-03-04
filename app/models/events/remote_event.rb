class RemoteEvent < Event
  require 'uri'
 # require 'remote_event_api_builder'
 require 'ccmeetup'
 require 'ccremote_event'

  attr_accessor :remote_api_key, :remember_api_key

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

  has_one :remote_event_api
#  has_many :remote_event_api_details

 # before_validation :populate_remote_event_api, on: :create
   after_create  :populate_remote_event_api, on: :create

#  validates :remote_event_api, presence: true
  validate :must_have_linked_events
  validate :must_have_remote_api_key

  def self.determine_url_source(url)
    uri = URI(url)
    hostname = uri.host
    ret = nil
    if hostname && REMOTE_SOURCE_HOST_MAP.has_key?(hostname)
      ret = REMOTE_SOURCE_HOST_MAP[hostname]
    end
    ret
  end

  def must_have_linked_events
    errors.add(:base, 'Must have at least one linked event') if linked_events.all?(&:marked_for_destruction?)
  end

  def must_have_remote_api_key
    unless (remote_api_key) 
      errors.add(:base, 'Must have a remote api key')
    end
  end

  def populate_remote_event_api
    re_api = RemoteEventApi.new
    re_api.remote_event_id = self.id
    if remember_api_key == 1
      re_api.api_key = remote_api_key
    end
    event_urls = []
    linked_events.map { |e| event_urls << e.url  }

    rclient = CCMeetup::Client.new({ auth_method: :api_key, api_key: remote_api_key })
    re = CCRemoteEvent::ApiBuilder.new(rclient)
    api = re.build(:meetup, { get_signed_url: true, url_list: event_urls, remember_api_key: remember_api_key })
    self.remote_event_api = api
  end

end
