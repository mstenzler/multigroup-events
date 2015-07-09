class ExcludedRemoteMember < ActiveRecord::Base
  belongs_to :remote_event, foreign_key: :event_id,  inverse_of: :excluded_remote_members
  belongs_to :remote_member, foreign_key: :remote_member_id, inverse_of: :excluded_remote_members

  include RemoteMemberCheck

#  accepts_nested_attributes_for :remote_member, reject_if: :all_blank, update_only: true
  accepts_nested_attributes_for :remote_member, reject_if: :check_remote_member, update_only: true

  VALID_EXCLUDE_MEMBER_TYPES = ['guests', 'user']
  EXCLUDE_GUESTS_TYPE = VALID_EXCLUDE_MEMBER_TYPES[0]
  EXCLUDE_USER_TYPE = VALID_EXCLUDE_MEMBER_TYPES[1]

  def self.valid_exclude_type?(type)
    VALID_EXCLUDE_MEMBER_TYPES.include?(type)
  end

  def self.display_type_options
    VALID_EXCLUDE_MEMBER_TYPES.map { |type| type.to_s }
  end

=begin
  protected

    def check_remote_member(member_attr)
      logger.debug("++++++++++++++++++++++++++++++++++++++++++++++++++++")
      logger.debug("***++** in check_remote_member. member_attr = #{member_attr.inspect}")
      if mem =  RemoteMember.where(remote_member_id: member_attr['remote_member_id'], 
         remote_source: member_attr['remote_source']).first
        logger.debug("GOT mem = #{mem.inspect}")
        self.remote_member = mem
        return true
      end
      return false
    end
=end

end
