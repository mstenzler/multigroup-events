class LinkedEvent < ActiveRecord::Base
  belongs_to :event

  validates :url, presence: true, allow_blank: false
end
