class EventView < Struct.new(:view)

  VALID_EVENT_VIEWS = ["upcoming", "past", "calendar", "mine"] 
  UPCOMING = VALID_EVENT_VIEWS[0]
  PAST = VALID_EVENT_VIEWS[1]
  CALENDAR = VALID_EVENT_VIEWS[2]
 # EVENT_VIEW_MINE = VALID_EVENT_VIEWS[3]

  DEFAULT_VIEW = UPCOMING

  def self.all_views
    VALID_EVENT_VIEWS
  end

  def is_calendar?
    view == CALENDAR
  end

  def is_valid?
    VALID_EVENT_VIEWS.include?(view)
  end

end