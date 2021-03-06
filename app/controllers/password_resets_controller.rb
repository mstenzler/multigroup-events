class PasswordResetsController < ApplicationController
  def new
  	set_is_new
  end

	def create
	  user = User.find_by_email(params[:email])
	  set_is_new
#	  p "in password_reset,create, user = #{user}, email = #{user.email}"
	  user.send_password_reset(@is_new) if user
	  label = @is_new ? "set password" : "password reset"
	  redirect_to root_url, :notice => "Email sent with #{label} instructions."
	end

	def edit
	  @user = User.find_by_password_reset_token!(params[:id])
	end

	def update
	  @user = User.find_by_password_reset_token!(params[:id])
	  if @user.password_reset_sent_at < User::PASSWORD_RESET_TTL_HOURS.hours.ago
	    redirect_to new_password_reset_path, :alert => "Password &crarr; 
	      reset has expired."
	  elsif @user.update_attributes(user_params)
	    redirect_to root_url, :notice => "Password has been reset."
	  else
	    render :edit
	  end
	end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def set_is_new
    	@is_new = (params[:type] && (params[:type] == "new"))
    end

end
