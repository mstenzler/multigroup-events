class RemoteGroup < ActiveRecord::Base
  has_many :remote_members
  belongs_to :geo_area
  
end
