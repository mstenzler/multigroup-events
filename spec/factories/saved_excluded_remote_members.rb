FactoryGirl.define do
  factory :saved_excluded_remote_member do
    user_id 1
remote_member_id 1
exclude_type "MyString"
  end

end
