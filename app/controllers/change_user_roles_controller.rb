class ChangeUserRolesController < ApplicationController
  before_action :signed_in_user
  before_action :init_form, only: [:edit, :update]

 	def edit
    authorize! :edit, @user
  end

 	def update
    authorize! :update, @user
	  if @user.update_attributes(user_params)
	    redirect_to edit_user_url(@user), :notice => "Roles have been updated."
	  else
	    render :edit
	  end
	end

  private
    def init_form
      @user = User.fetch_user(params[:id])
#      @user = current_user
    end

    def user_params
      params.require(:user).permit(:roles=>[])
    end
end
