require 'rest-client'
class Authentication < ActiveRecord::Base
	belongs_to :user

  scope :by_provider, -> provider { where(provider_name: provider) if provider.present? }

  def provider_name
  	provider.titleize
  end

  def is_last_auth?
  	(!user.has_local_authentication? && (user.num_authentications <= 1)) ? true : false
  end

  def can_edit_api_key?
    CONFIG[:omniauth_providers_with_key].include? provider
  end

  def has_api_key?
    !api_key.blank?
  end

  def update_credentials(omniauth)
    info = omniauth['info'] || {}

    cred = omniauth['credentials']
    unless cred
      raise "Don't have credentials in omniauth hash"
    end
    self.token = cred['token'] if cred['token']
    self.token_secret = cred['token_secret'] if cred['token_secret']
    self.refresh_token = cred['refresh_token'] if cred['refresh_token']
    self.expires_at = Time.at(cred['expires_at']) if cred['expires_at']
    self.expires = (cred['expires'] =~ /false/i ? false : true) if cred['expires']
    logger.debug("About to save new credentials!")
    self.save
  end

  def get_fresh_token
  	refresh_token_if_expired
  	token
  end

	def refresh_token_if_expired
	  if token_expired?
	  	case self.provider
	  	when "meetup"
	  		refresh_meetup_token
	  	when "facebook"
	  		refresh_facebook_token
	  	else
	  		raise "Invalid oauth2 provider in refresh_token"
	  	end

	    self.save
#	    puts 'Saved'
	  end
	end

	def refresh_meetup_token
		  logger.debug("About to make refresh tocken request with: 
		  	refresh_token = #{self.refresh_token}, 
		  	client_id = #{Rails.application.secrets.meetup_key}
		  	secret_id = #{Rails.application.secrets.meetup_secret}
		  	")
		  response = nil
		  begin
		    response    = RestClient.post "https://secure.meetup.com/oauth2/access", 
		    :grant_type => 'refresh_token', 
		    :refresh_token => self.refresh_token, 
		    :client_id => Rails.application.secrets.meetup_key,
		    :client_secret =>  Rails.application.secrets.meetup_secret
		  rescue => e
		    logger.debug("GOT ERROR: response = #{e.response.inspect}")
		  end

		  if response
		    logger.debug("response.body = #{response.body.inspect}")
		    refreshhash = JSON.parse(response.body)
	#	    token_will_change!
	#	    token_expires_at_will_change!

		    self.token  = refreshhash['access_token']
		    self.refresh_token  = refreshhash['refresh_token']
		    self.expires_at = DateTime.now + refreshhash["expires_in"].to_i.seconds
		    logger.debug("new token = #{self.token}, token_expires_at = #{self.expires_at}")
		  end
	end

	def refresh_facebook_token

	end

	def token_expired?
	  expiry = self.expires_at ? Time.at(self.expires_at) : nil 
	  return true if expiry && expiry < Time.now # expired token, so we should quickly return
#	  token_expires_at = expiry
#	  save if changed?
	  false # token not expired. :D
	end
end
