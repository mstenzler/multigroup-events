class SavedExcludedMembersController < ApplicationController
  before_action :signed_in_user
  before_action :init_form

 	def edit
	  if @user
      if (@user.saved_excluded_remote_members.size <= 0)
        @user.saved_excluded_remote_members.build().build_remote_member
      end
    else
	  	display_error("Current user does not exist")
	  end
	end

 	def update
	  unless @user
	  	display_error("Current user does not exist")
	  	return
	  end
	  if @user.update_attributes(user_params)
	    redirect_to edit_user_url(@user), :notice => "Saved Excluded Users have been updated."
	  else
	    render :edit
	  end
	end

  private

    def init_form
      @user = current_user
      @user.populate_excluded=true
    end

    def user_params
      params.require(:user).permit(saved_excluded_remote_members_attributes: [:id, :_destroy, :exclude_type, remote_member_attributes: [:id, :remote_source, :remote_member_id]])
    end

end
