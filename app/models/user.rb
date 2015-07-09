class User < ActiveRecord::Base
  rolify
  belongs_to :geo_country
  belongs_to :geo_area
  has_one :profile
  has_many :events
  has_many :authentications

  has_many :saved_excluded_remote_members, dependent: :destroy, inverse_of: :user
  accepts_nested_attributes_for :saved_excluded_remote_members, 
    reject_if: :check_saved_remote_member, allow_destroy: true, update_only: true
  has_many :excluded_remote_members, through: :saved_excluded_remote_members, 
            source: :remote_member

  before_create :create_remember_token
  before_create :init_new_user
  before_create :init_profile

	before_save { email.downcase! }
  before_save { username.try(:downcase!) }

  before_save :update_age
  after_save :populate_excluded_remote_members, :if => :populate_excluded?

  mount_uploader :avatar, AvatarUploader
  
  attr_accessor :verify_token, :unhashed_email_validation_token, 
                :zip_code, :auth_type

  VALIDATION_CODE_RESET_MESSAGE = "Your email validation code has been reset and emailed to you."

  PASSWORD_RESET_TTL_HOURS = CONFIG[:password_reset_ttl_hours] || 2

  DEFAULT_FRIENDLY_ID_COLUMN = :username

#  ROLES = %i[admin organizer member banned]

  NAME_MAX_LENGTH = 32
  NAME_MIN_LENGTH = 2
  USERNAME_MAX_LENGTH = 24
  USERNAME_MIN_LENGTH = 2
  EMAIL_MAX_LENGTH = 50
  EMAIL_MIN_LENGTH = 4
	
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  VALID_NAME_REGEX = /\A[a-z\d\-\_\.\&\s]+\z/i
  VALID_USERNAME_REGEX = /\A[a-z]{1}[a-z\d\-\_]+\z/i

  AUTH_TYPES = ["local", "omniauth"]
  AUTH_LOCAL = AUTH_TYPES[0]
  AUTH_OMNIAUTH = AUTH_TYPES[1]
  
  AGE_DISPLAY_TYPES = ["Hidden", "Number", "Range"]

  AGE_DISPLAY_HIDDEN = AGE_DISPLAY_TYPES[0]
  AGE_DISPLAY_NUMBER = AGE_DISPLAY_TYPES[1]
  AGE_DISPLAY_RANGE = AGE_DISPLAY_TYPES[2]

  AGE_RANGE_MAP = [ 
    { min: 0, max: 17, text: "Under 18 years old"},
    { min: 18, max: 25, text: "18-25 years old"},
    { min: 26, max: 35, text: "26-35 years old"},
    { min: 36, max: 45, text: "36-45 years old"},
    { min: 46, max: 55, text: "36-55 years old"},
    { min: 56, max: 65, text: "56-65 years old"},
    { min: 66, max: 75, text: "66-75 years old"},
    { min: 76, max: 200, text: "76 years or older"}    
  ]


  VALID_GENDERS = ["Male", "Female", "Transgender", "Other"]
  MALE_VALUE = VALID_GENDERS[0]
  FEMALE_VALUE = VALID_GENDERS[1]
  TRANSGENDER_VALUE = VALID_GENDERS[2]
  OTHER_GENDER_VALUE = VALID_GENDERS[3] 

  VALID_AVATAR_TYPES = ["None", "Gravatar", "Upload"]
  NO_AVATAR = VALID_AVATAR_TYPES[0]
  GRAVATAR_AVATAR = VALID_AVATAR_TYPES[1]
  UPLOAD_AVATAR = VALID_AVATAR_TYPES[2]

  GRAVATAR_SIZE_MAP = { tiny: "50", small: "70", medium: "100", large: "150"}
  GRAVITAR_DEFAULT_SIZE = GRAVATAR_SIZE_MAP[:small]
  IMAGE_RESIZE_MAP = { tiny: [30, 30], small:[60, 60] , medium: [100, 100], 
                     large: [200, 200], original: [400, 400] }

   
  DEFAULT_AVATAR_DIR = CONFIG[:default_avatar_dir] || "/images/default_avatar"

  START_YEAR = 1900
  VALID_DATES = DateTime.new(START_YEAR)..DateTime.now
  CURRENT_YEAR = DateTime.now.year

  MIN_AGE = CONFIG[:min_age].blank? ? nil : CONFIG[:min_age].to_i
  MAX_AGE = CONFIG[:max_age].blank? ? nil : CONFIG[:max_age].to_i 
  HAS_USER_EDIT_FIELDS = (CONFIG[:enable_name?] || CONFIG[:enable_gender?] || 
                          CONFIG[:enable_birthdate?] || CONFIG[:enable_time_zone?] )

  name_can_be_blank = CONFIG[:require_name?] ? false : true
  username_can_be_blank = CONFIG[:require_username?] ? false : true
  gender_can_be_blank = CONFIG[:require_gender?] ? false : true
  birthdate_can_be_blank = CONFIG[:require_birthdate?] ? false : true
  time_zone_can_be_blank = CONFIG[:require_time_zone?] ? false : true
  country_can_be_blank = CONFIG[:require_country?] ? false : true
  zip_code_can_be_blank = CONFIG[:require_zip_code?] ? false : true

  #For each of the user_form_options define require_#{option_name} and
  #enable_#{option_name} methods and make each one a helper method as well
  CONFIG[:user_form_options].each do |option_name|
    enable_name = "enable_#{option_name}".to_sym
    require_name = "require_#{option_name}".to_sym
    use_name = "use_#{option_name}".to_sym
    define_method enable_name do
      CONFIG[enable_name]
    end
#    helper_method enable_name
    define_method require_name do
      CONFIG[require_name]
    end
#    helper_method require_name
    define_method use_name do 
      new_record? ? CONFIG[require_name] : CONFIG[enable_name]
    end
  end

  has_secure_password validations: false

  validates :password, presence: true, allow_blank: false, 
  confirmation: true, length: { minimum: 6 }, on: :create, 
  if: lambda { |u| u.password_required? }

  validates :name, allow_blank: name_can_be_blank, presence: !name_can_be_blank, 
            format: { with: VALID_NAME_REGEX },
            length: {minimum: NAME_MIN_LENGTH, maximum: NAME_MAX_LENGTH},
            if: "CONFIG[:enable_name?]"

  validates :geo_country, allow_blank: country_can_be_blank, presence: !country_can_be_blank,
            if: "CONFIG[:enable_country?]"
  validates :zip_code, allow_blank: zip_code_can_be_blank, presence: !zip_code_can_be_blank, 
            on: :create, if: "CONFIG[:enable_zip_code?]"
  validates :username, allow_blank: username_can_be_blank, presence: !username_can_be_blank, 
            format: { with: VALID_USERNAME_REGEX },
            uniqueness: { case_sensitive: false},
            length: {minimum: USERNAME_MIN_LENGTH, maximum: USERNAME_MAX_LENGTH},
            if: "CONFIG[:enable_username?]"
 
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  validates :gender, allow_blank: gender_can_be_blank, presence: !gender_can_be_blank, 
             inclusion: { in: VALID_GENDERS },
            if: "CONFIG[:enable_gender?]"
  validates :time_zone, allow_blank: time_zone_can_be_blank, presence: !time_zone_can_be_blank, 
             inclusion: { in: ActiveSupport::TimeZone.zones_map(&:name).keys },
            if: "CONFIG[:enable_time_zone?]"

  validates_associated :saved_excluded_remote_members

  if CONFIG[:enable_birthdate?]
#    p "IN enable_birthdate validation. MIN_AGE = #{MIN_AGE}. birthdate_can_be_blank = #{birthdate_can_be_blank}"
    date_hash = { allow_blank: birthdate_can_be_blank }
    if !MIN_AGE.nil?
      date_hash.merge!(before: Proc.new { MIN_AGE.years.ago }, before_message: "must be at least #{MIN_AGE} years old")
    end
    if !MAX_AGE.nil?
      date_hash.merge!(on_or_after: Proc.new{ MAX_AGE.years.ago }, on_or_after_message: "Cannot be more than #{MAX_AGE} years old")
    end
    validates_date :birthdate,  date_hash
  end

  if CONFIG[:use_friendly_name_id?]
    extend FriendlyId
    friendly_id_column = CONFIG[:user_identity_field] ? CONFIG[:user_identity_field].to_sym : DEFAULT_FRIENDLY_ID_COLUMN
    friendly_id friendly_id_column

    def self.fetch_user(id)
      User.friendly.find(id)
    end
  elsif CONFIG[:user_identity_field] == 'username'
    def to_param
      self.username
    end

#    def self.find(identifier)
    def self.fetch_user(id)
      self.find_by_username(id)
    end
  end

  def User.find_by_identity(ident, args={})
    field = CONFIG[:user_identity_field]
#    puts "args = #{args.inspect}"
#    puts "arg class = args.class.inspect"
    ret = where(field => ident)
    if args[:include]
      ret = ret.includes(args[:include])
    end
    ret.first
  end

  def User.username_taken?(uname)
    where(username: uname).take ? true : false
  end
  
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def User.make_hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
  
  def User.build_default_avatar_url(opts={})
    size = opts[:size] || nil
    gender = opts[:gender] || nil
    filename = size.nil? ? "avatar.png" : "#{size.to_s.downcase}_avatar.png"
    if gender.nil?
      "#{DEFAULT_AVATAR_DIR}/default/{filename}"
    else
      "#{DEFAULT_AVATAR_DIR}/#{gender.to_s.downcase}/#{filename}" 
    end
  end

  def User.display_age_range(age, map = AGE_RANGE_MAP)
    ret = ""
    logger.debug("map = #{map.inspect}")
    if (age)
      map.each do |map_item|
        logger.debug("map_item = #{map_item.inspect}")
        logger.debug("age = '#{age}', min = '#{map_item[:min]}', max = '#{map_item[:max]}'")
        if age >= map_item[:min] && age <= map_item[:max] 
          ret = map_item[:text]
          break
        end
      end
    else
      logger.warn("WARNING! Age not specified in display_age_range")
    end
    ret
  end

  def populate_excluded?
    logger.debug("+++++====+++ in populate_excluded. val = #{@populate_excluded}")
    !!@populate_excluded
  end

  def populate_excluded=(val)
    @populate_excluded = val
  end

  def num_saved_excluded_members
    saved_excluded_remote_members.size()
  end

  def has_saved_excluded_members
    saved_excluded_remote_members.size() > 0
  end

  def num_saved_excluded_members_for_print
    ret = "None"
    if saved_excluded_remote_members
      ret = "(#{saved_excluded_remote_members.size()})"
    end
    ret
  end

  def excluded_remote_member_id_list
    excluded_remote_members.map { |mem| mem.remote_member_id }
  end

  def excluded_remote_guest_member_id_list
    saved_excluded_remote_members.select { |mem| mem.exclude_type == ExcludedRemoteMember::EXCLUDE_GUESTS_TYPE}.map { |mem| mem.remote_member.remote_member_id }
  end

  def excluded_remote_user_member_id_list
    saved_excluded_remote_members.select { |mem| mem.exclude_type == ExcludedRemoteMember::EXCLUDE_USER_TYPE}.map { |mem| mem.remote_member.remote_member_id }
  end
 
  def excluded_remote_member_list(discard_id_arr = nil)
    ret = nil
    logger.debug("-------------------------------")
    logger.debug("discard_id_arr = #{discard_id_arr.inspect}")
    if (discard_id_arr)
      #discard_id_arr_str = discard_id_arr.map { |id| id.to_s }
      logger.debug("excluded_remote_members = #{excluded_remote_members.inspect}")
      logger.debug("discard_id_arr = #{discard_id_arr.inspect}")
      ret = excluded_remote_members.reject { |mem| logger.debug("*_*-*- remote_member_id = #{mem.remote_member_id}"); discard_id_arr.include?(mem.remote_member_id) }
      logger.debug("*******______******-----ret = #{ret.inspect}")
    else
      ret = excluded_remote_members
    end
    ret
  end

  def excluded_members_list_for_print
    ret = "None"
    list = nil
    if saved_excluded_remote_members
      list = saved_excluded_remote_members.map { |mem| mem.remote_member.remote_member_id }
      if list.size > 0
        ret = list.join(',')
      end
    end
    ret
  end

  def auth_api_keys
    ret = nil
    if authentications
      ret = authentications.map { |auth| { provider: auth.provider_name, key: auth.api_key } if auth.api_key.present? }
    end
    ret
  end

  def authentication_for_meetup
    ret = nil
    logger.debug("++==++ in authentication_for_meetup!")
    if authentications
      names = authentications.map { |au| au.provider }
      logger.debug("** names = #{names.inspect}")
      list = authentications.select { |auth| auth.provider == RemoteEvent::MEETUP_NAME }
      if (list.size > 0)
        ret = list[0]
      end
    end
    ret
  end
  
  def role_names(cast_to = nil)
    cast_func = nil
    if cast_to
      case cast_to.to_sym
      when :symbol
        cast_func = "to_sym"
      when :string
        cast_func = "to_s"
      else
        raise "Invalid cast_to param: #{cast_to} in role_names"
      end
    end
    roles.map { |r| cast_func ? r.name.send(cast_func) : r.name }
  end

  def roles_list_for_print(sep = ', ')
    l_roles = roles
    ret = nil
    if (l_roles && l_roles.size > 0)
      ret = l_roles.map { |r| r.name.to_s.titleize }.join(sep)
    else
      ret = "None"
    end
    ret
  end

=begin
  def roles=(roles)
    roles = [*roles].map { |r| r.to_sym }
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask.to_i || 0) & 2**ROLES.index(r)).zero?
    end
  end

  
  def roles_list_for_print(sep = ', ')
    l_roles = roles
    ret = nil
    if (l_roles && l_roles.size > 0)
      ret = l_roles.map { |r| r.to_s.titleize }.join(sep)
    else
      ret = "None"
    end
    ret
  end

  def has_role?(role)
    roles.include?(role)
  end
=end

  def has_local_authentication?
    !password_digest.blank?
  end

  def num_authentications
    authentications.length
  end

  def password_required?
    (authentications.empty? || !password.blank?)
  end

  def display_age_range
    ret = ""
    if (age)
      ret = self.class.display_age_range(age)
    else
      if CONFIG[:require_birthdate?]
        logger.warn("WARNING! Age not specified for user.id #{self.id}")
      end
    end
    ret
  end

  def display_age
    ret = ""
    case self.age_display_type
    when AGE_DISPLAY_HIDDEN
      ret = "Private"
    when AGE_DISPLAY_NUMBER
      ret = self.age
    when AGE_DISPLAY_RANGE
      ret = display_age_range
    else
      raise "No valid display age: #{self.age_display_type} in display_age"
    end
    ret
  end

  def display_location
    self.geo_area.display
  end

 # def to_param
 #   self.username || self.id
 # end

  def zip_code
    @zip_code || geo_area.try(:zip)
  end

#  def self.find(identifier)
#    self.find_by_username(identifier)
#  end

  def init_unvalidated_email
    if CONFIG[:verify_email?]
      token = User.new_token
      logger.debug("Setting new email validation token to '#{token}'")
      self.unhashed_email_validation_token = token
      self.email_validation_token = User.make_hash(token)
      self.email_validated = false
    end
    self.email_changed_at = Time.zone.now
    self.email.downcase!
  end

  def reset_email(new_email)
    self.email = new_email
    init_unvalidated_email
    save!
  end

  def reset_email_validation_token(overide_token=nil)
    #helpful for testing
    token = overide_token.nil? ? User.new_token : overide_token
    self.unhashed_email_validation_token = token
    hashed_token = User.make_hash(token)
    self.email_validation_token = hashed_token
    self.email_validated = false
    self.save!
    { token: token, hashed_token: hashed_token}
  end

  def send_email_validation_token
    unless self.email_validation_token && self.unhashed_email_validation_token
      raise "email_validation_token is not set when attempting to email the validation code"
    end
    UserMailer.email_validation_token(self).deliver
  end

  def send_email_changed_validation_token
    unless self.email_validation_token && self.unhashed_email_validation_token
      raise "email_validation_token is not set when attempting to change the email validation code"
    end
    UserMailer.changed_email_validation_token(self).deliver
  end

  def send_password_reset(is_new = false)
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self, is_new).deliver
  end

  def set_create_ip_addresses(adr)
    self.ip_address_created = self.ip_address_last_modified = adr
  end
  
  def validate_email
    self.update_attribute :email_validated, true
  end
  
  def generate_token(column, use_hash=false)
    begin
      token = use_hash ? User.make_hash(User.new_token) : User.new_token
      self[column] = token
    end while User.exists?(column => self[column])
  end

  def avatar_url(size=nil)
    logger.debug("IN AVATAR_URL. size = '#{size}'")
 #   check_avatar_size(size) if size
    size = size.to_sym if (!size.nil? && size.class != Symbol)
    ret = nil

    logger.debug("IN avatar_url. avatar_type = '#{avatar_type}'")
    case avatar_type
    when GRAVATAR_AVATAR
      ret = gravatar_url(size ? GRAVATAR_SIZE_MAP[size] : nil)
    when UPLOAD_AVATAR 
      logger.debug("In UPLOAD_AVATAR. avatar = #{avatar}. avatar.blank = #{avatar.blank?}")
      if !avatar.nil?
        logger.debug("setting ret to uploaded avatar image")
        ret = avatar.url(size)
      else
        logger.debug("Using default avatar image")
        ret = default_avatar_url(size)
      end
    else
      ret = default_avatar_url(size)
    end
    ret.to_s
  end

  def has_avatar?
    ([GRAVATAR_AVATAR, UPLOAD_AVATAR].include? avatar_type) && !avatar.blank?
  end

  def default_avatar_url(size=:small)
    if CONFIG[:use_avatar_gender_default?]
      case gender
      when MALE_VALUE
        User.build_default_avatar_url(size: size, gender: MALE_VALUE)
      when FEMALE_VALUE
        User.build_default_avatar_url(size: size, gender: FEMALE_VALUE)
      else
        User.build_default_avatar_url(size: size, gender: OTHER_GENDER_VALUE)
      end
    else
      User.build_default_avatar_url(size: size)
    end
  end

  def gravatar_url(current_size = GRAVITAR_DEFAULT_SIZE)
    current_size ||= GRAVITAR_DEFAULT_SIZE
    logger.debug("GRAVATAR_URL: size = '#{current_size}'")
    gravatar_id = Digest::MD5::hexdigest(email.downcase)
    size = nil
    if (current_size.is_a? String) 
       size = current_size
     elsif (current_size.is_a? Symbol)
      check_avatar_size(current_size)
       size = GRAVATAR_SIZE_MAP[current_size]
     elsif (current_size.is_a? Integer)
       size = "#{current_size}"
     else
      raise ArgumentError, "gravatar_url(#{current_size}) is an invalid size argument"
    end
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end

=begin
  def personal_enabled?
    (self.profile && self.profile.enable_personal) ? true : false
  end

  def enable_personal_profile
    self.transaction do
      self.profile.update_attribute(:enable_personal, true)
      unless self.personal_profile
        self.create_personal_profile
      end
    end
    return true
  end

  def disable_personal_profile
    self.profile.update_attribute(:enable_personal, false)
  end
=end

  def apply_omniauth(omniauth)
    info = omniauth['info'] || {}
    self.name = info['name'] if info['name'] && !self.name
    self.email = info['email'] if info['email'] && !self.email
    args = {
      provider: omniauth['provider'], 
      uid: omniauth['uid']
    }
    cred = omniauth['credentials']
    unless cred
      raise "Don't have credentials in omniauth hash"
    end
    args[:token] = cred['token'] if cred['token']
    args[:token_secret] = cred['token_secret'] if cred['token_secret']
    args[:refresh_token] = cred['refresh_token'] if cred['refresh_token']
    args[:expires_at] = Time.at(cred['expires_at']) if cred['expires_at']
    args[:expires] = (cred['expires'] =~ /false/i ? false : true) if cred['expires']
    logger.debug("About to build authentications with args = #{args.inspect}")
    authentications.build(args)
  end

#  def password_required?
#    (authentications.empty? || !password_digest.blank?)
#  end

    def proccess_geo_area
      unless (self.geo_country_id && self.zip_code)
        if CONFIG[:require_country?] || CONFIG[:require_zip_code?]
          raise "Error. Tring to proccess geo_area without a country_id & zip"
        else
          return false
        end
      end
      geo_area = GeoArea.get_or_create_geo_area(self.geo_country_id, self.zip_code)

      if geo_area
        self.geo_area_id = geo_area.id
        return true
      else
        errors.add(:geo_area, "Zip code is not valid")
        return false
      end #area
    end

  private

    def check_saved_remote_member(member_attr)
      ret = false
      mem_id = member_attr['remote_member_attributes']['remote_member_id']
      id = member_attr['id']
      logger.debug("*===****++++=====*****======****")
#      logger.debug("mem_id = #{mem_id}")
#      logger.debug("member_attr = #{member_attr}.inspect")
#      logger.debug("id = #{id}")
 
      if (mem_id.blank?)
        #if remote_member_id is blank, reject it.
        logger.debug("remote_member_id is blank")
        ret = true
      elsif (id)
        #if id is present then working on an already saved object so don't reject
        ret = false
      else
        #make sure remote_member_id is an integer
        mem_id_int = Integer(mem_id) rescue nil
        exclude_type = member_attr['exclude_type']
        logger.debug("mem_id_int = #{mem_id_int}, exclude_type = #{exclude_type}")
        #Get the current saved guests or user list depending on
        #the current attribute exclude_type
        curr_member_id_list = nil
        case exclude_type 
        when ExcludedRemoteMember::EXCLUDE_GUESTS_TYPE
          curr_member_id_list = excluded_remote_guest_member_id_list
        when  ExcludedRemoteMember::EXCLUDE_USER_TYPE
          curr_member_id_list = excluded_remote_user_member_id_list
        end
            logger.debug("existing_ids = #{curr_member_id_list.inspect}")
        #If we have saved members for this exclude type check to see that
        #the current member attempting to be saved is not already included
        if (mem_id_int && curr_member_id_list && curr_member_id_list.size > 0)
          logger.debug("comparing to see if id: #{mem_id_int} is in list #{curr_member_id_list.inspect}")
          if (curr_member_id_list.include?(mem_id_int))
            logger.debug("Attempting to add already existing ID. Rejecting")
            ret = true
          end
        end
      end
      logger.debug("ret value = #{ret}")
      ret
    end

    def populate_excluded_remote_members
      logger.debug("+++++====+++ in populate_excluded_remote_members!!")

      auth = authentication_for_meetup
      logger.debug("++ auth = #{auth.inspect}")
      if auth
        api = RemoteUserApiMeetup.new(auth)
        ids = excluded_remote_members.map { |mem| mem.remote_member_id }
        if (ids && ids.size > 0)
          remote_member_arr = api.get_remote_members(ids)
          #logger.debug("**&*&&**&** remote_memmbers = #{remote_member_arr.inspect}")

          remote_member_hash = {}
          remote_member_arr.each do |rm|
            logger.debug("rm.id = #{rm.id}")
            curr_id = rm.id
            if (curr_id)
              remote_member_hash[curr_id] = rm
            else
              logger.error("ERROR. no ID for remote_member: #{rm}")
            end
          end
          excluded_remote_members.each do |lrm|
            logger.debug("Iteration. lrm = #{lrm.inspect}")
            logger.debug("lrm.remote_member_id = #{lrm.remote_member_id}")
            curr_rm = remote_member_hash[lrm.remote_member_id]
            logger.debug("curr_rm = #{curr_rm}")
            if (curr_rm)
              lrm.name = curr_rm.name if curr_rm.name
              lrm.bio = curr_rm.bio if curr_rm.bio
              lrm.country = curr_rm.country if curr_rm.country
              lrm.city = curr_rm.city if curr_rm.city
              lrm.state = curr_rm.state if curr_rm.state
              lrm.gender = curr_rm.gender if curr_rm.gender
              lrm.hometown = curr_rm.hometown if curr_rm.hometown
              lrm.lat = curr_rm.lat if curr_rm.lat
              lrm.lon = curr_rm.lon if curr_rm.lon
              lrm.joined = curr_rm.joined  if curr_rm.joined 
              lrm.link = curr_rm.link if curr_rm.link
              lrm.membership_count = curr_rm.membership_count if curr_rm.membership_count
              if (photo = curr_rm.photo)
                lrm.photo_high_res_link = photo.high_res_link if photo.high_res_link
                lrm.photo_id = photo.photo_id if photo.photo_id
                lrm.photo_link = photo.photo_link if photo.photo_link
                lrm.photo_thumb_link = photo.thumb_link if photo.thumb_link
              end
              lrm.last_visited = curr_rm.last_visited if curr_rm.last_visited
              lrm.save!
              logger.debug("updated lrm = #{lrm.inspect}")
            end
          end                 
        end
      end
    end

    def check_gravatar_size(size)
      unless GRAVATAR_SIZE_MAP.keys.include?(size)
        raise ArgumenError, "gravatar size '#{size}' is not a valid size argument"
      end
    end

    def create_remember_token
      self.remember_token = User.make_hash(User.new_token)
    end

    def create_validation_token
      self.validation_token = User.make_hash(User.new_token)
    end

    def init_new_user
      self.avatar_type ||= NO_AVATAR
      self.age_display_type ||= AGE_DISPLAY_NUMBER
      if CONFIG[:enable_country?] && CONFIG[:enable_zip_code?]
        proccess_geo_area unless self.geo_area 
      end
      if new_record?
        init_unvalidated_email
      end
    end

    def init_profile
      if new_record?
        self.build_profile
      end
    end

    def update_age(do_save=true)
      new_age = calculate_age
      Rails.logger.debug("IN update_age. new_age = #{new_age.inspect}")
#      self.age = new_age
#      self.age_last_checked = Time.zone.now
      if do_save
        #self.save(:validate => false)
        if (new_age != age)
          self.update_attribute(:age, new_age)
          self.update_attribute(:age_last_checked, Time.zone.now)
        end
      end
      new_age
    end

    def update_age!
      update_age(true)
    end

    def calculate_age
      return nil if birthdate.nil?
      today = Date.today
      new_age = 0
      if (today.month > birthdate.month) or
         (today.month == birthdate.month and today.day >= birthdate.day)
        # Birthdate has happened already this year.
        new_age = today.year - birthdate.year
      else
        new_age = today.year - birthdate.year - 1
      end
      new_age
    end

end
