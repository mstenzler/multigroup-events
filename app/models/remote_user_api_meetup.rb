class RemoteUserApiMeetup < RemoteUserApi
  require 'ccmeetup'

  def initialize(auth)
    super(auth)
    unless (@authentication.provider == MEETUP_NAME)
      raise "Must supply a Meetup Provider to #{self.class.name}.#{__method__}"
    end
    set_remote_client
    unless (@remote_client)
      raise "Could not instantiate remote client in #{self.class.name}.#{__method__}"
    end
  end

  def get_upcoming_events_rsvpd_to(args={})
    opts = { member_id: self.remote_member_id, status: "upcoming", rsvp: "yes", get_signed_url: true }
    fields = args[:fields]
    if (fields)
      opts[:fields] = fields
    end
    remote_client.fetch(:events, opts)
  end

  def get_remote_members(member_id_arr)
    member_id_list = member_id_arr.map { |id| id.to_i}.join(',')
    remote_client.fetch(:members, { member_id: member_id_list })
  end

  def get_joined_groups(member_id)
    remote_client.fetch(:groups, { member_id: member_id })
  end
  
  private

    def set_remote_client
      @remote_client =  ::CCMeetup::Client.new({ auth_method: :oauth2, authentication: @authentication })
    end
end
