module AuthenticationsHelper

  def is_authenticated?(provider)
    ret = false
    provider_s = provider.to_s
    unless (provider_s && valid_omniauth_provider(provider_s))
      raise "Invalid provider: '#{provider}' in  #{self.class.name}.#{__method__}"
    end
    provider_sym = provider.to_sym
    auth = Authentication.by_provider(provider_sym)
    if (auth && token = auth.get_fresh_token)
      ret = true
    end
    ret
  end

  def valid_omniauth_provider?(provider)
    CONFIG[:omniauth_providers].include?(provider) ? true : false
  end

end
