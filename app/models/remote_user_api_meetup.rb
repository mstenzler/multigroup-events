class RemoteUserApiMeetup < RemoteUserApi
  require 'ccmeetup'

  def initialize(auth)
    super(auth)
    unless (@authentication.provider == MEETUP_NAME)
      raise "Must supply a Meetup Provider to #{self.class.name}.#{__method__}"
    end
    set_remote_client
    unless (@remote_client)
      raise "Counld not instantiate remote client in #{self.class.name}.#{__method__}"
    end
  end

  def get_upcoming_events_rsvpd_to
    remote_client.fetch(:events, { member_id: self.remote_member_id, status: "upcoming", rsvp: "yes", get_signed_url: true })
  end

  private

    def set_remote_client
      @remote_client =  ::CCMeetup::Client.new({ auth_method: :oauth2, authentication: @authentication })
    end
end
