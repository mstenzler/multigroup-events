class SavedExcludedRemoteMember < ActiveRecord::Base
  belongs_to :user, inverse_of: :saved_excluded_remote_members
  belongs_to :remote_member, inverse_of: :saved_excluded_remote_members

  include RemoteMemberCheck

  accepts_nested_attributes_for :remote_member, reject_if: :check_remote_member, update_only: true

  validates :exclude_type, presence: true, 
             inclusion: { in: ExcludedRemoteMember::VALID_EXCLUDE_MEMBER_TYPES }

  validates_associated :remote_member 

=begin
  protected

    def check_remote_member(member_attr)
      logger.debug("++++++++++++++++++++++++++++++++++++++++++++++++++++")
      remote_member_id = member_attr['remote_member_id']
      logger.debug("***++** in check_remote_member. member_attr = #{member_attr.inspect}")
      if mem =  RemoteMember.where(remote_member_id: member_attr['remote_member_id'], 
         remote_source: member_att['remote_source'])
        logger.debug("GOT mem = #{mem.inspect}")
        self.remote_member = mem
        return true
      end
      return false
    end
=end

end
