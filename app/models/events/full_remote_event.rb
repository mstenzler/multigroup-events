class FullRemoteEvent < RemoteEvent

  def self.sti_base_class
    Event
  end

#  require friendly_title_helper
  include FriendlyTitleHelper
  include SetModelNameHelper

end
