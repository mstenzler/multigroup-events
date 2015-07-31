class AddRsvpDisplayPrivacyToEvents < ActiveRecord::Migration
  def change
    add_column :events, :rsvp_display_privacy, :string, :limit => 24, :default => 'public'
    add_column :events, :rsvp_count_display_privacy, :string, :limit => 24, :default => 'public'
    add_column :events, :show_event_hosts, :boolean, :default => true
  end
end
