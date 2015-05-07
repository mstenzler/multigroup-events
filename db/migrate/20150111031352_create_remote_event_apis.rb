class CreateRemoteEventApis < ActiveRecord::Migration
  def change
    create_table :remote_event_apis do |t|
      t.integer :remote_event_id
      t.text :options
      t.integer :primary_remote_event_info_id
      t.integer :primary_remote_event_index, default: 0
      t.string :all_events_api_url
      t.string :all_rsvps_api_url
      t.string :api_key

      t.timestamps
    end
  end
end
