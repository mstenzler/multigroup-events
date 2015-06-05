class RemoteEventApiSource < ActiveRecord::Base
  belongs_to :remote_event_api, inverse_of: :remote_event_api_sources
  belongs_to :event_venue
  before_validation :extract_event_source_id

#  validates :url, presence: true
  validates :event_source_id, presence: true

  NEW_RANK_MARKER = "__NEW_RANK_MARKER__"

#  validate :must_have_url_or_id

  def source
    remote_event_api.remote_source
  end

  def is_primary?
    is_primary_event ? true : false
  end

  private

    def extract_event_source_id
      if (url)
        if (is_a_number?(url))
          self.event_source_id = url
          self.url = nil
        elsif (is_valid_source_url?(url))
          s_id = extract_event_source_id_from_url(url)
          if (s_id)
            self.event_source_id = s_id
          else
            errors.add(:base, "Could not get event source id from url '#{url}'")
          end
        else
          errors.add(:base, "Event '#{url}' is not a valid url for #{source}")
        end
      end
    end

    def is_valid_source_url?(source_url)
      ret = false
      p "source = '#{source}'"
      case source
      when RemoteEvent::MEETUP_NAME
        ret = check_meetup_source_url(source_url)
      when RemoteEvent::FACEBOOK_NAME
        ret = check_facebook_source_url(source_url)
      else
        raise "Invalid Source: #{source} in is_valid_source_url"
      end
      ret
    end  

    def check_meetup_source_url(src_url)
      /www.meetup.com\/[\w\-\_]+\/events\/\d+\//i.match(src_url) ? true : false
    end

    def check_facebook_source_url(src_url)
      /www.facebook.com\/events\/\d+\//i.match(src_url) ? true : false
    end

    def is_a_number?(str)
      /\A\d+\Z/.match(str) ? true : false
    end

    def extract_event_source_id_from_url(source_url)
      ret = false
      case source
      when RemoteEvent::MEETUP_NAME
        ret = extract_meetup_event_id_from_source_url(source_url)
      when RemoteEvent::FACEBOOK_NAME
        ret = extract_facebook_event_id_from_source_url(source_url)
      else
        raise "Invalid Source: #{source} in extract_event_id"
      end
      ret      
    end

    def extract_meetup_event_id_from_source_url(src_url)
      m = /www.meetup.com\/[\w\-\_]+\/events\/(\d+)\//i.match(src_url)
      m ? m[1] : nil
    end 
    def extract_facebook_event_id_from_source_url(src_url)
      m = /www.facebook.com\/events\/(\d+)\//i.match(src_url)
      m ? m[1] : nil
    end 

    def must_have_url_or_id
      has_key = remote_event_api.api_key.empty? ? false : true
      unless (has_key) 
        errors.add(:base, 'Must have an api key')
      end
    end
end
