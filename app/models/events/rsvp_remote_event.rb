class FullRemoteEvent < Event
 
  require friendly_title_helper
  include FriendlyTitleHelper

  validates :remote_event_api, presence: true
  validate :must_have_linked_events

  def must_have_linked_events
    errors.add(:base, 'Must have at least one linked event') if linked_events.all?(&:marked_for_destruction?)
  end
 
end
