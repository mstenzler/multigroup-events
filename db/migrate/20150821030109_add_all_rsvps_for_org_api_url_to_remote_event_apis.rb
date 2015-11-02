class AddAllRsvpsForOrgApiUrlToRemoteEventApis < ActiveRecord::Migration
  def change
    add_column :remote_event_apis, :all_rsvps_for_org_api_url, :text
  end
end
