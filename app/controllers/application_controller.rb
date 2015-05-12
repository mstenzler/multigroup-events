class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  around_filter :user_time_zone, if: :configure_user_time_zone?
  helper_method :gravatar_for

  include SessionsHelper
  include ControllerFormatDate
  
  DEFAULT_ERROR_MESSAGE = "A Error has occured"

  #For each of the user_form_options define require_#{option_name} and
  #enable_#{option_name} methods and make each one a helper method as well
  CONFIG[:user_form_options].each do |option_name|
  	enable_name = "enable_#{option_name}".to_sym
  	require_name = "require_#{option_name}".to_sym
  	use_name = "use_#{option_name}".to_sym
  	define_method enable_name do
  		CONFIG[enable_name]
  	end
  	helper_method enable_name
  	define_method require_name do
  		CONFIG[require_name]
  	end
  	helper_method require_name
  	define_method use_name do |user_object|
  		user_object.new_record? ? CONFIG[require_name] : CONFIG[enable_name]
  	end
  	helper_method use_name
  end

  def signed_in_user
  	unless signed_in?
  		store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  def gravatar_for(user, options = { size: 50 })
    gravatar_url = gravatar_url(user, options)
    gravatar_class = options[:class] || "gravatar"
    ActionController::Base.helpers.image_tag(gravatar_url, alt: user.name, class: gravatar_class)
  end

  def gravatar_url(user, options = { size: 50 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size] || User::GRAVATAR_SIZE_MAP[:small]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end

  def display_error(err=nil)
    message = nil
    unless err.nil?
      message = err.is_a?(String) ? err : (err.try(:message) ? err.message : nil)
    end
    flash[:notice] = (!message.nil? && 
      (Rails.env.development? || Rails.env.test?)) ? message : DEFAULT_ERROR_MESSAGE
    redirect_to error_url
  end

  private

    def configure_user_time_zone?
      CONFIG[:configure_user_time_zone] && current_user
    end

    #enables each individual user to use a specific time zone if selected
    def user_time_zone(&block)
      logger.debug("in user_time_zone")
 #     Time.use_zone(current_user.time_zone, &block) if !current_user.time_zone.blank?
       time_zone = current_user.try(:time_zone) || CONFIG[:default_time_zone] || 'UTC'
       Time.use_zone(time_zone, &block)
      logger.debug("End user_time_zone")
    end

end
