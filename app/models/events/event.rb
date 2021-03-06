class Event < ActiveRecord::Base
  resourcify
  belongs_to :user
  belongs_to :event_venue
#  has_one :remote_event_api
#  has_many :linked_events, :dependent => :delete_all
#  accepts_nested_attributes_for :linked_events

  require 'friendly_title_helper'
  include FriendlyTitleHelper

  #Causes an error when loading event types if event_type class not loaded
  require 'event_type'

  attr_accessor :current_user, :update_slug
  alias_method :update_slug?, :update_slug

  scope :listed, -> { where(display_listing: true) }
  scope :upcoming, -> { where("end_date >= ? OR start_date >= ?", Time.zone.now, Time.zone.now - 3.hours).order(:start_date) }
  scope :past, -> { where("start_date <= ?",  Time.zone.now).order(start_date: :desc) }
  scope :by_month, -> date { 
    if (date.present?)
      unless (date.is_a?(Date))
        date = date.to_date
      end
      where("start_date >= ? and start_date <= ? ", date.beginning_of_month, date.end_of_month )
    end
  }
  scope :by_user, -> user { where(user_id: user.id) if user.present? }
  scope :by_home_page, -> num { where("start_date >= ? AND show_home_page = ?",  Time.zone.now - 3.hours, true).order(priority: :desc, start_date: :asc).limit(num) }

  MEETUP_PROVIDER = "meetup"

  VALID_DISPLAY_STATES = ["visible", "invisible", "hidden"]
  VISIBLE_DISPLAY_STATE = VALID_DISPLAY_STATES[0]
  INVISIBLE_DISPLAY_STATE = VALID_DISPLAY_STATES[1]
  HIDDEN_DISPLAY_STATE = VALID_DISPLAY_STATES[2]

  VALID_NOT_VISIBLE_REASONS = ["not_logged_in", "not_authenticated", "not_authorized", "not_logged_in_and_authenticated", "not_member"]
  NOT_LOGGED_IN_REASON = VALID_NOT_VISIBLE_REASONS[0]
  NOT_AUTHENTICATED_REASON = VALID_NOT_VISIBLE_REASONS[1]
  NOT_AUTHORIZED_REASON = VALID_NOT_VISIBLE_REASONS[2]
  NOT_LOGGED_IN_AND_AUTHENTICATED_REASON = VALID_NOT_VISIBLE_REASONS[3]
  NOT_MEMBER_REASON = VALID_NOT_VISIBLE_REASONS[4]

  VALID_DISPLAY_PRIVACY_TYPES = ["public", "private", "registered", "group_members"]
  PUBLIC_DISPLAY_PRIVACY = VALID_DISPLAY_PRIVACY_TYPES[0]
  PRIVATE_DISPLAY_PRIVACY = VALID_DISPLAY_PRIVACY_TYPES[1]
  REGISTERED_DISPLAY_PRIVACY = VALID_DISPLAY_PRIVACY_TYPES[2]
  GROUP_MEMBERS_DISPLAY_PRIVACY = VALID_DISPLAY_PRIVACY_TYPES[3]

  EVENT_TYPES_FILE = "#{Rails.root}/config/event_types.yml"
  EVENT_TYPES = YAML::load(File.open(EVENT_TYPES_FILE))

  VALID_EVENT_TABS = EventView::VALID_EVENT_VIEWS  
  EVENT_TAB_UPCOMING = EventView::UPCOMING
  EVENT_TAB_PAST = EventView::PAST 
  EVENT_TAB_CALENDAR = EventView::CALENDAR
#  EVENT_TAB_MINE = EventView::EVENT_VIEW_MINE

  validates :title, presence: true, allow_blank: false
  validates_format_of :url_identifier, :with => /\A[-_a-z0-9]+\Z/i, allow_blank: true, :on => [:create, :update]

  def self.get_no_display_alert_message(display_type, no_display_reason, label = "Note!")
    ret = nil
    reason = nil
    target = nil
    additinal = ""

    case display_type 
    when :event
      target = "event details"
    when :rsvp
      target = "user RSVP's"
    when :rsvp_count
      target = "RSVP count"
    else
      target = "content"
    end

    case no_display_reason
    when NOT_LOGGED_IN_REASON
      reason = "You must be logged in to"
    when NOT_AUTHENTICATED_REASON, NOT_LOGGED_IN_AND_AUTHENTICATED_REASON
      reason = "you must be logged in through Meetup to"
    when NOT_AUTHORIZED_REASON
      reason = "you are not authorized to"
    when NOT_MEMBER_REASON
      reason = "you must be a member of one of the participating groups to"
    else 
      reason = "you can't"
    end
    ret = "#{label} #{reason} view the #{target}"
  end

  def self.event_tab_options
    VALID_EVENT_TABS
  end

  def self.event_tab_regex
    VALID_EVENT_TABS.join('|')
  end

  def self.display_privacy_options
    [PUBLIC_DISPLAY_PRIVACY, PRIVATE_DISPLAY_PRIVACY, REGISTERED_DISPLAY_PRIVACY, GROUP_MEMBERS_DISPLAY_PRIVACY]
  end

  def self.get_sublcass_select_arr
    arr = EVENT_TYPES.sort {|a,b| a.rank<=>b.rank}
    arr.collect {|p| [ p.title, p.name ]}
  end

  def self.get_default_event_type
    arr = EVENT_TYPES.select { |et| et.is_default }
    return ( (arr.length > 0) ? arr[0] : EVENT_TYPES[0])
  end 

  def self.valid_event_type?(type)
    EVENT_TYPES.index { |x| x.name == type } ? true : false
  end

  def self.get_event_type(type)
    ind = EVENT_TYPES.index { |x| x.name == type }
    return ind ? EVENT_TYPES[ind] : nil
  end

  def self.get_event_types
    return EVENT_TYPES
  end

  def should_generate_new_friendly_id?
    slug.blank? || (title_changed? && update_slug?)
  end

  def num_linked_events
    linked_events ? linked_events.size : 0
  end

  def type_title
    self.class.name.underscore.humanize.titleize
  end

  def event_type
    @event_type ||= self.class.get_event_type(self.class.name)
  end

  def utc_offset_in_hours
    ret = nil
    if (utc_offset)
      ret = (utc_offset/1000)/3600
    end
    ret
  end

  def start_date_local
    to_local_time(start_date)
  end

  def end_date_local
    to_local_time(end_date)
  end

  def to_local_time(time)
    ret = nil
    if (time)
 #     logger.debug("@@@--@@ in to_local_time. time = #{time}")
      if (timezone)
 #       logger.debug("Converting useing timezone: #{timezone}")
        ret = time.in_time_zone(timezone)
      elsif (utc_offset)
 #       logger.debug("converting using utc_offset_in_hours: #{utc_offset_in_hours}")
        ret = time.in_time_zone(utc_offset_in_hours)
      end
 #     logger.debug("returning time: #{ret}")
    end
    ret
  end

end
