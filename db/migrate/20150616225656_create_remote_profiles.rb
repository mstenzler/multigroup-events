class CreateRemoteProfiles < ActiveRecord::Migration
  def change
    create_table :remote_profiles do |t|
      t.integer :remote_member_id
      t.integer :remote_group_id
      t.string :bio
      t.string :role,  :limit => 16
      t.string :comment
      t.datetime :created
      t.datetime :last_updated
      t.string :photo_high_res_link
      t.string :photo_link
      t.string :photo_thumb_link
      t.integer :photo_id

      t.timestamps
    end

    add_index "remote_profiles", ["remote_member_id"], :name => "remote_profiles_memid_opt"
    add_index "remote_profiles", ["remote_group_id"], :name => "remote_profiles_groupid_opt"

  end
end
