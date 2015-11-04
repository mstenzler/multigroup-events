class UsersController < ApplicationController
  #redirect if user is not signed in
	before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
  #redirectif user is signed in
	before_action :is_signed_in,   only: [:new, :create]
  before_action :load_user, :only => [:show, :edit, :update, :destroy]
  before_action :check_privileges!, only: [:edit, :update, :destroy]
#  load_and_authorize_resource
#  skip_authorize_resource :only => [:new, :create, :index]
  #before_action :correct_user,   only: [:edit, :update]
  #before_action :admin_user,     only: :destroy
  #before_action :is_signed_in,   only: [:new, :create]

  def index
  	@users = User.paginate(page: params[:page])
  end

	def show
    puts 'IN SHOW!!!'
    logger.debug("IN user show")
    #@user = User.find(params[:id])
    logger.debug("Got user = #{@user.inspect}")
  end

  def new
  	@user = new_user
    logger.debug("user.name = #{@user.name}")
#    @countries = GeoCountry.get_country_list({default_country: CONFIG[:default_country],
#                                              force_reaload: true})
    load_new_user_info
  end

  def create
    @user = new_user(user_params)  
#    p "IN CREATE: @user.gender = '#{@user.gender}', @user.birthdate = '#{@user.birthdate}'"
    @user.set_create_ip_addresses(request.remote_ip)
    if @user.save
      profile = @user.build_profile
      profile.save
    	sign_in @user
      session[:omniauth] = nil
      if CONFIG[:verify_email?]
        @user.send_email_validation_token
        redirect_to new_user_verify_email_path(@user)
#        render 'show_verify_email'
      else
    	  flash[:success] = "Welcome. You have registered for the site!"
        redirect_to @user
      end
    else
      load_new_user_info
      render 'new'
    end
  end

  def edit
    #@user = User.fetch_user(params[:id])
    #@user = current_user
    load_new_user_info
  end

  def update
    #@user = User.fetch_user(params[:id])
    @curr_user = current_user
    authorize! :assign_roles, @user if params[:user][:assign_roles]
    if @user.update_attributes(user_params)
    	flash[:success] = "Profile updated"
      redirect_to @user
      # Handle a successful update.
    else
      load_new_user_info
      render 'edit'
    end
  end

  def destroy
    #user = User.find(params[:id])
    #user = User.fetch_user(params[:id])
    if (current_user == user) && (current_user.admin?)
    	flash[:error] = "Can not delete own admin acount!"
    else
    	user.destroy
      flash[:success] = "User deleted."
    end
    redirect_to users_url
  end

=begin
  def verify_email
    @user = User.find(params[:id])
    verify_token = params[:verify_token]
    if verify_token
      if @user.email_validation_token == User.hash(verify_token)
        @user.validate_email
        render 'verify_email_success'
      else
        flash[:error] = "Not a valid email validation token for this user"
        render 'show_verify_email'
      end
    else
      render 'show_verify_email'
    end
  end
=end

  def username_taken?(uname)
    User.username_taken?
  end

  private

    def user_params
      params.require(:user).permit(:name, :username, :email, :password,
                                   :password_confirmation, :gender, :birthdate,
                                   :geo_country_id, :zip_code,
                                   :age_display_type, :time_zone)
    end

    def load_user
      @user ||= User.fetch_user(params[:id])
    end

    def check_privileges!
      @user || load_user
      if @user 
        logger.debug("Check_priveleges!. Got user = #{@user.inspect}")
        authorize! :manage, @user, :message => "You are not authorized to perform this action!"
      else
        display_error("Could not retrieve user object for this page")
      end
    end

    def load_new_user_info
      if CONFIG[:enable_country?]
        @countries = GeoCountry.get_country_list({default_country: CONFIG[:default_country],
                                              force_reaload: true})
      end
    end

    # Before filters

#    def signed_in_user
#    	unless signed_in?
#    		store_location
#        redirect_to signin_url, notice: "Please sign in."
#      end
#    end

    def correct_user
#      user = User.find(params[:id])
      user = User.fetch_user(params[:id])
      redirect_to(root_url) unless current_user?(user)
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

    def is_signed_in
    	redirect_to(root_url) if signed_in?
    end

    def new_user(user_params = {})
      user = User.new(user_params)
      omni = session[:omniauth]
      logger.debug("IN new_user!!!. session = #{omni}")
      if omni
        logger.debug("About to call user.apply_omniauth")
        user.apply_omniauth(omni)
        user.auth_type = User::AUTH_OMNIAUTH
      else
        user.auth_type = User::AUTH_LOCAL
      end
      user
    end
end
