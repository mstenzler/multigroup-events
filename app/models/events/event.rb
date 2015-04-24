class Event < ActiveRecord::Base
  belongs_to :user
#  has_one :remote_event_api
  has_many :linked_events
  accepts_nested_attributes_for :linked_events

  require 'friendly_title_helper'
  include FriendlyTitleHelper

  #Causes an error when loading event types if event_type class not loaded
  require 'event_type'

  VALID_DISPLAY_PRIVACY_TYPES = ["public", "private", "registered", "group_members"]
  PUBLIC_DISPLAY_PRIVACY = VALID_DISPLAY_PRIVACY_TYPES[0]
  PRIVATE_DISPLAY_PRIVACY = VALID_DISPLAY_PRIVACY_TYPES[1]
  REGISTERED_DISPLAY_PRIVACY = VALID_DISPLAY_PRIVACY_TYPES[2]
  GROUP_MEMBERS_DISPLAY_PRIVACY = VALID_DISPLAY_PRIVACY_TYPES[3]

  EVENT_TYPES_FILE = "#{Rails.root}/config/event_types.yml"
  EVENT_TYPES = YAML::load(File.open(EVENT_TYPES_FILE))

  validates :title, presence: true, allow_blank: false

  def self.display_privacy_options
    [PUBLIC_DISPLAY_PRIVACY, PRIVATE_DISPLAY_PRIVACY, REGISTERED_DISPLAY_PRIVACY]
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

  def num_linked_events
    linked_events ? linked_events.size : 0
  end

  def type_title
    self.class.name.underscore.humanize.titleize
  end

end
