FactoryGirl.define do
  factory :excluded_remote_member do
    remote_user_id 1
event_id 1
exclude_type "MyString"
  end

end
