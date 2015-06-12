class EventView < Struct.new(:view)

  VALID_EVENT_VIEWS = ["upcoming", "past", "calendar", "mine"] 
  EVENT_VIEW_UPCOMING = VALID_EVENT_VIEWS[0]
  EVENT_VIEW_PAST = VALID_EVENT_VIEWS[1]
  EVENT_VIEW_CALENDAR = VALID_EVENT_VIEWS[2]
  EVENT_VIEW_MINE = VALID_EVENT_VIEWS[3]

  DEFAULT_VIEW = EVENT_VIEW_UPCOMING

  def self.all_views
    VALID_EVENT_VIEWS
  end

  def is_calendar?
    view == EVENT_VIEW_CALENDAR
  end

  def is_valid?
    VALID_EVENT_VIEWS.include?(view)
  end

end