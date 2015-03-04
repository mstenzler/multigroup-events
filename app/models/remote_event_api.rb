class RemoteEventApi < ActiveRecord::Base
  belongs_to :remote_event
  has_many :remote_event_api_details
end
