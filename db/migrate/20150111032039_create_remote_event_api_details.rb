class CreateRemoteEventApiDetails < ActiveRecord::Migration
  def change
    create_table :remote_event_api_details do |t|
      t.integer :remote_event_api_id
      t.integer :rank
      t.string :event_url
      t.string :event_api_url
      t.string :rsvp_api_url
      t.string :remote_event_id
      t.string :title
      t.text :description
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
