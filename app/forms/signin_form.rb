class SigninForm
  include ActiveModel::Model

  NO_PASSWORD_ERROR = 1
  NO_USER_ERROR = 2
  USER_ID_LABEL = CONFIG[:enable_username?] ? "Username or Email" : "Email"

  def persisted?
    false
  end

  attr_accessor :user_id, :password, :remember_me, :form_error
  attr_writer :target_user

  validates_presence_of :user_id
  validates_presence_of :password
  validate :verify_username_and_password

#  def initialize(user, token=nil)
#    @user = user
#    self.verify_token = token unless token.blank?
#  end
 
#    user = User.find_by(email: params[:session][:email].downcase)
#    if user && user.authenticate(params[:session][:password])
 
  def submit(params)
  	self.user_id = params[:user_id] unless params[:user_id].blank?
  	self.password = params[:password] unless params[:password].blank?
  	self.remember_me = params[:remember_me] unless params[:remember_me].blank?
    if (self.user_id && !target_user_exists?)
      self.form_error = NO_USER_ERROR
      return false
    elsif (self.user_id && !target_user_has_password_set?)
      self.form_error = NO_PASSWORD_ERROR
      return false
    else
      if valid?
      	true
      else
        false
      end
    end
  end

  def verify_username_and_password
  	unless target_user_authenticates?
  		errors.add :password, "does not match User"
  	end
  end

  def target_user_authenticates?
  	target_user && target_user.authenticate(self.password)
  end

  def get_user
  	target_user_authenticates? ? target_user : nil
  end

  private

    def target_user
  	  @target_user ||= get_user_from_id(self.user_id)
    end

    def target_user_has_password_set?
      target_user && target_user.has_password_set?
    end

    def target_user_exists?
      target_user ? true : false
    end

  	def is_email(str)
  		!str.blank? && str.match(User::VALID_EMAIL_REGEX)
  	end

    #get the user by either the email or username
  	def get_user_from_id(user_id)
  		user = nil
  		unless user_id.blank?
	  		col = :email
	  		if CONFIG[:enable_username?]
	  			unless is_email(user_id)
	  				col = :username
	  			end
	  		end
#	  		p "Finding user by col: #{col}, user_id = #{user_id}"
	  		user = User.find_by(col => user_id.downcase)
	  	end
	  	user
  	end

end