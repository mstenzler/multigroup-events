class LocalEvent < Event
 
  include FriendlyTitleHelper
  include SetModelNameHelper

  validates :description, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
#  validates :location, presence: true  
  
end
