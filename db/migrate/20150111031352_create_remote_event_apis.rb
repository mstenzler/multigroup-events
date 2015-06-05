class CreateRemoteEventApis < ActiveRecord::Migration
  def change
    create_table :remote_event_apis do |t|
      t.integer :remote_event_id
      t.string :remote_source, :limit => 126
      t.text :options
      t.string :primary_remote_event_source_id, :limit => 56
      t.integer :primary_remote_event_index, default: 0
      t.string :all_events_api_url
      t.string :all_rsvps_api_url
      t.string :api_key
      t.boolean :remember_api_key, default: false
      t.boolean :set_remote_date
      t.boolean :set_remote_venue
      t.boolean :set_remote_description
      t.boolean :set_remote_fee

      t.timestamps
    end
  end
end
