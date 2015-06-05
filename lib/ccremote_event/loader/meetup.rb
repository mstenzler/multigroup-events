module CCRemoteEvent
  module Loader

    class MisingArgumentsError < StandardError
      def initialize(msg)
        msg ||= "Missing arguments"
        super "Argument Error: #{msg}."
      end
    end

    class BadArgumentError < StandardError
      def initialize(msg)
        msg ||= "Bad argument"
        super "Bad Argument Error: #{msg}."
      end
    end

    class BadApiClientError < StandardError
      def initialize(msg)
        msg ||= "Api Client Misconfigoured"
        super "Api Client Error: #{msg}."
      end
    end

    class BadlyFormatedEventUrlError < StandardError; end
    class ApiReturnMissingElementError < StandardError; end

    class Meetup < Base

      DEFAULT_EVENT_STATUS = "upcoming,past"
      BASE_MEETUP_URL = "http://www.meetup.com"

      #this nakes the remote events and rsvps api calls and updates the remote_event_api
      #with the restulst from the calls. 
      #:remote_event_api and api_client must either be passed in when initialed or
      #passed as options to load
      def load(options={})
        use_signed_url = options.has_key?(:get_signed_url) ? options[:signed_url] : false
        loc_remote_event_api = options[:remote_event_api] || remote_event_api
        loc_api_client = options[:api_client] || api_client
        unless (loc_api_client)
          raise MisingArgumentsError.new("Must set an api_client for #{self.class.name}")
        end
        unless (loc_remote_event_api)
          raise MisingArgumentsError.new("Must set a remote_event_api for #{self.class.name}")
        end

        load_remote_event_api(loc_api_client, loc_remote_event_api, options)
      end

      private

        def load_remote_event_api(loc_api_client, 
                                  loc_remote_event_api, options = {})
          api_key = nil
          if (loc_api_client.authenticator.respond_to?(:api_key))
            api_key = loc_api_client.authenticator.api_key
          else
            raise BadApiClientError.new("api_client does not respond to api_key in #{self.class.name}.#{__method__}")
          end

          event_id_list = loc_remote_event_api.event_id_list
          unless (event_id_list)
            raise BadArgumentError.new("Could not get event_id_list from loc_remote_event_api in #{self.class.name}.#{__method__}")
          end

          unless (event_id_list.size > 0)
            raise BadArgumentError.new("event_id_list is empty in #{self.class.name}.#{__method__}")
          end
          event_status = options.has_key?("event_status") ? 
            options[:event_status] : DEFAULT_EVENT_STATUS
          id_list = event_id_list.join(',')
          puts("id_list = '#{id_list}'")
    #      puts("api_detail_hash = '#{api_detail_hash.inspect}'")
          all_events_info = loc_api_client.fetch(:events, { event_id: id_list, status: event_status, get_signed_url: true })
          all_rsvps_info =  loc_api_client.fetch(:rsvps, { event_id: id_list, get_signed_url: true })
#          puts("all_events_info = '#{all_events_info}'")
#          puts("all_rsvps_info = '#{all_rsvps_info}'")

          add_all_events_info_to_event_api(loc_remote_event_api, all_events_info, all_rsvps_info)
        
        end

        #note this function modifies remote_event_api
        def add_all_events_info_to_event_api(remote_event_api, all_events_info, all_rsvps_info)
          unless (all_events_info.signed_url)
            raise ApiReturnMissingElementError, "signed_url missing from api return of all events"
          end
          unless (all_rsvps_info.signed_url)
            raise ApiReturnMissingElementError, "signed_url missing from api return of all rsvps"
          end
          remote_event_api.all_events_api_url = all_events_info.signed_url
          remote_event_api.all_rsvps_api_url = all_rsvps_info.signed_url

          #Iterate through the events returned by the API and
          #create add the details to the RemoteEventAPIDetail objs
          all_events_info.each do |event_info|
            curr_event_id = event_info.id.to_s.to_sym
            puts("curr_event_id = '#{curr_event_id}'. class_name = '#{curr_event_id.class.name}'")
            curr_api_source = remote_event_api.get_source_by_event_id(curr_event_id)
            if (curr_api_source)
              curr_api_source.url = event_info.event_url
              curr_api_source.title = event_info.name
              event_fee = event_info.event_fee
              if (event_fee)
                curr_api_source.fee_accepts = event_fee.accepts
                curr_api_source.fee_amount = event_fee.amount
                curr_api_source.fee_currency = event_fee.currency
                curr_api_source.fee_description = event_fee.description
                curr_api_source.fee_label = event_fee.label
                curr_api_source.fee_required = event_fee.reqired
              end
              event_group = event_info.group
              puts "event_group = #{event_group.inspect}"
              if (event_group)
                curr_api_source.group_name = event_group["name"]
                curr_api_source.group_url = construct_meetup_group_url(event_group["urlname"])
              end
              curr_api_source.description = event_info.description
              if (event_info.time) 
                puts "event_info.time = #{event_info.time}"
                #loc_start_date = Time.at(event_info.time)
                curr_api_source.start_date = event_info.time
                puts "start_date = #{curr_api_source.start_date}"
                if (time_delta = event_info.duration)
                  puts "event_info.duration = #{event_info.duration}"
                  puts "time_delta = '#{time_delta}'"
                  start_date_in_ms = event_info.time.strftime('%Q').to_i
                  loc_end_time = Time.at((start_date_in_ms + time_delta)/1000)
                  puts "loc_end_time = '#{loc_end_time}'"
                  curr_api_source.end_date = loc_end_time
                  puts "end_date = #{curr_api_source.end_date}"
                end
              end
              if (venue = event_info.venue)
                puts "About to find or create EventVenue. venue = #{venue.inspect}"
                event_venue = EventVenue.find_or_create_for_meetup(venue)
                puts("event_venue = #{event_venue.inspect}")
                curr_api_source.event_venue_id = event_venue.id
                puts "event_venue_id = curr_api_source.event_venue_id"
#                curr_api_source.build_event_venue(event_venue.attributes)
              end
            else
              puts("ERROR! Did not have an api_source for '#{curr_event_id}'")
            end
          end
          remote_event_api
        end

        def convertUrlListToEventIdList(eventUrlList)
          unless (eventUrlList && eventUrlLilst.size  > 0)
            return nil
          end

          ret = []
          eventUrlList.each do |url|
            if (event_id = getEventId(url))
              ret << event_id
            else
              raise BadlyFormatedEventUrlError, "Could not get id from event url #{url}"
            end
          end
          ret
        end

        def getEventId(url)
          res = url.match(/events\/(\d+)/)
          ret = nil
          if (res && res[1])
            ret = res[1]
          end
          ret
        end

        def construct_meetup_group_url(url_name="")
          BASE_MEETUP_URL + "/" + url_name
        end

    end

  end
end