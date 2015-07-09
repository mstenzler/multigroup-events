module RemoteMemberCheck

  def check_remote_member(member_attr)
    Rails.logger.debug("++++++++++++++++++++++++++++++++++++++++++++++++++++")
    Rails.logger.debug("***++** in check_remote_member. member_attr = #{member_attr.inspect}")
    if mem =  RemoteMember.where(remote_member_id: member_attr['remote_member_id'], 
       remote_source: member_attr['remote_source']).first
      Rails.logger.debug("GOT mem = #{mem.inspect}")
      self.remote_member = mem
      return true
    end
    return false
  end

end