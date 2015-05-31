class CreateRemoteEventApiSources < ActiveRecord::Migration
  def change
    create_table :remote_event_api_sources do |t|
      t.integer :remote_event_api_id, null: false
      t.integer :rank
      t.string :url, null: false
      t.text :event_api_url
      t.text :rsvp_api_url
      t.string :event_source_id
      t.string :title
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.string :group_name
      t.string :group_url
      t.integer :remote_group_id
      t.boolean :is_primary_event, default: false

      t.timestamps
    end
  end
end
