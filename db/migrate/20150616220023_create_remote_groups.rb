class CreateRemoteGroups < ActiveRecord::Migration
  def change
    create_table :remote_groups do |t|
      t.string :name
      t.string :remote_source, :limit => 126
      t.text :description
      t.integer :remote_group_id
      t.string :urlname
      t.string :link
      t.string :join_mode, :limit => 24
      t.string :visibility, :limit => 24
      t.integer :members
      t.integer :remote_organizer_profile_id
      t.float :lat
      t.float :lon
      t.string :timezone, :limit => 124
      t.string :state,    :limit => 100
      t.string :city,     :limit => 200
      t.string :country,  :limit => 100
      t.integer :geo_area_id
      t.datetime :created

      t.timestamps
    end

    add_index "remote_groups", ["remote_group_id"], :name => "remote_groups_groupid_opt"
    add_index "remote_groups", ["remote_organizer_profile_id"], :name => "remote_groups_orgprofile_opt"
    add_index "remote_groups", ["geo_area_id"], :name => "remote_groups_geo_area_opt"

  end
end
