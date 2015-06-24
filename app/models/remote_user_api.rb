class RemoteUserApi < RemoteApi

  attr_accessor :authentication, :remote_client, :remote_member_id

  def initialize(auth)
    @authentication = auth
    @remote_member_id = auth.uid
  end

end
