class RemoteProfile < ActiveRecord::Base
  belongs_to :remote_member
  belongs_to :remote_group
  
end
