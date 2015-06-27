class RemoteMember < ActiveRecord::Base
#  belongs_to :remote_member
  has_many :excluded_remote_members, inverse_of: :remote_member
  has_many :saved_excluded_remote_members, inverse_of: :remote_member
  has_many :users_excluded_by, through: :saved_excluded_remote_members,
            source: :user
#  has_many :excluded_guests, -> { where exclude_type: ExcludedRemoteMember::EXCLUDE_GUESTS_TYPE },
#           class_name: "ExcludedRemoteMember", foreign_key: :remote_member_id, inverse_of: :remote_member

  validates :remote_source, presence: true, 
             inclusion: { in: CONFIG[:remote_api_sources] }

  has_many   :remote_profiles
  belongs_to :geo_area

  def thumb_photo_src
    self.photo_thumb_link ? self.photo_thumb_link : CONFIG[:default_no_photo_src]
  end

end
