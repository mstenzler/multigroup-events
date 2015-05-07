class RemoteEventApi < ActiveRecord::Base
  belongs_to :remote_event
  has_many :remote_event_api_details

  DEFAULT_PRIMARY_REMOTE_EVENT_INDEX = 0
end
