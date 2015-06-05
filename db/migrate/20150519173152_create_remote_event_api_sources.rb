class CreateRemoteEventApiSources < ActiveRecord::Migration
  def change
    create_table :remote_event_api_sources do |t|
      t.integer :remote_event_api_id, null: false
      t.integer :rank
      t.string :url, null: false
      t.text :event_api_url
      t.text :rsvp_api_url
      t.string :event_source_id, :limit => 56
      t.string :title
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :last_modified
      t.integer :utc_offset
      t.string :timezone, :limit => 124
      t.string :group_name
      t.string :group_url
      t.boolean :is_primary_event, default: false
      t.boolean :announced
      t.datetime :announced_at
      t.string :how_to_find_us
      t.string :publish_status, :limit => 24
      t.string :venue_visiblity, :limit => 24
      t.string :visibilty, :limit => 24
      t.integer :yes_rsvp_count, default: 0
      t.string :fee_accepts, :limit => 16
      t.float  :fee_amount
      t.string :fee_currency, :limit => 16
      t.string :fee_description, :limit => 24
      t.string :fee_label, :limit => 16
      t.boolean :fee_required
      t.integer :remote_group_id
      t.integer :event_venue_id

      t.timestamps
    end
  end
end
