class AuthenticationsController < ApplicationController
  before_action :signed_in_user, except: [:create]
  before_action :init_form, only: [:edit, :update]

  def index
    @authentications = current_user.authentications if current_user
    @authentications ||= []
  end

  def create
    logger.debug("*** in authentications_controller.create!!!")
    omniauth = request.env["omniauth.auth"]
#    p "omniauth = #{omniauth.inspect}"
    authentication = omniauth ? Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid']) : nil
#    p "authentication = #{authentication.inspect}"
    if authentication
      logger.debug("About to call authentication.update_credentials(omniauth)")
      authentication.update_credentials(omniauth)
      flash[:notice] = "Signed in successfully"
      logger.debug("About to sign_in")
      sign_in(authentication.user, CONFIG[:default_remember_me] || false)
      redirect_to authentication.user
    elsif current_user
      authentication = current_user.authentications.create(provider: omniauth['provider'], uid: omniauth['uid'])
      authentication.update_credentials(omniauth)
      flash[:notice] = "Authentication Succesfull"
      redirect_to authentications_url
    else
      user = User.new
      user.apply_omniauth(omniauth) if omniauth
      #user.authentications.build(provider: omniauth['provider'], uid: omniauth['uid'])
      if user.save
        flash[:notice] = "Signed in successfully"
        sign_in(user, CONFIG[:default_remember_me] || false)
        redirect_to user
      else
        session[:omniauth] = omniauth.except('extra')
        logger.debug("About to redirect to signup_url. session = #{session[:omniauth].inspect}")
        redirect_to signup_url
      end
    end
  
  end

  def edit
  end

  def update
    if @authentication.update_attributes(auth_params)
      redirect_to authentications_url, :notice => "Api key has been updated."
    else
      render :edit
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    puts "About to destroy authentication #{@authentication.inspect}"
    @authentication.destroy
    redirect_to authentications_url, :notice => "Successfully destroyed authentication."
  end

  private
    def init_form
      @authentication = current_user.authentications.find(params[:id])
      authorize! :manage, @authentication
    end

    def auth_params
      params.require(:authentication).permit(:api_key)
    end
end
