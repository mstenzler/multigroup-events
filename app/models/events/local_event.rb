class LocalEvent < Event
  require friendly_title_helper
  include FriendlyTitleHelper

  validates :description, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
#  validates :location, presence: true  
  
end
