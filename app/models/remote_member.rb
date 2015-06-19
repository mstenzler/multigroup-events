class RemoteMember < ActiveRecord::Base
#  belongs_to :remote_member
  has_many :excluded_remote_members, inverse_of: :remote_member
#  has_many :excluded_guests, -> { where exclude_type: ExcludedRemoteMember::EXCLUDE_GUESTS_TYPE },
#           class_name: "ExcludedRemoteMember", foreign_key: :remote_member_id, inverse_of: :remote_member


  has_many   :remote_profiles
  belongs_to :geo_area

end
