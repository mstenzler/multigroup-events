module CCRemoteEvent
  module Builder

    class MisingArgumentsError < StandardError
      def initialize(msg)
        msg ||= "Missing arguments"
        super "Argument Error: #{msg}."
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

      def build(options={})
        use_signed_url = options.has_key?(:get_signed_url) ? options[:signed_url] : false
        url_list = options[:url_list]
        loc_api_client = options[:api_client] || api_client
        unless (url_list)
          raise MisingArgumentsError.new("Must pass url_list to #{sef.class.name}.build")
        end
        unless (loc_api_client)
          raise MisingArgumentsError.new("Must set an api_client for #{sef.class.name}")
        end

        ret = build_remote_event_api(url_list, loc_api_client, options)
      end

      private

        def build_remote_event_api(url_list, loc_api_client, options={})
          if (loc_api_client.authenticator.respond_to?(:api_key))
            api_key = loc_api_client.authenticator.api_key
          else
            raise BadApiClientError.new("api_client does not respond to api_key")
          end
 
          ret = RemoteEventApi.new
          if (options[:remember_api_key])
            ret[:api_key] = api_key
          end
          ret.api_key = options[:api_key] if options.has_key?(:api_key)
          event_api_details = []
          rank = 1
          remote_event_id_arr = []
          api_detail_hash = {}
          event_status = options.has_key?("event_status") ? 
            options[:event_status] : DEFAULT_EVENT_STATUS
          ret.primary_remote_event_index = 
           options.has_key?(:primary_remote_event_index) ? 
           options[:primary_remote_event_index] : RemoteEventApi::DEFAULT_PRIMARY_REMOTE_EVENT_INDEX

          url_list.each do |url|
            remote_event_id = getEventId(url)
            unless (remote_event_id)
              raise BadlyFormatedEventUrlError, "Could not get id from event url #{url}"
            end
            remote_event_id_arr << remote_event_id
            detail = RemoteEventApiDetail.new
            detail.rank = rank
            rank += 1
            detail.event_url = url
            detail.remote_event_id = remote_event_id
            api_detail_hash[remote_event_id.to_sym] = detail
          end
          id_list = remote_event_id_arr.join(',')
          puts("id_list = '#{id_list}'")
          puts("api_detail_hash = '#{api_detail_hash.inspect}'")
          all_events_info = loc_api_client.fetch(:events, { event_id: id_list, status: event_status, get_signed_url: true })
          all_rsvps_info =  loc_api_client.fetch(:rsvps, { event_id: id_list, get_signed_url: true })
#          puts("all_events_info = '#{all_events_info}'")
#          puts("all_rsvps_info = '#{all_rsvps_info}'")

          add_all_events_info_to_ret(ret, all_events_info, all_rsvps_info, api_detail_hash, remote_event_id_arr)
          puts "*** About to Return obj ***"
          puts "ret = #{ret.inspect}"
          puts "ret.remote_event_api_details = #{ret.remote_event_api_details.inspect}"
          ret
        end

        #note this function modifies ret
        def add_all_events_info_to_ret(ret, all_events_info, all_rsvps_info, api_detail_hash, id_arr)
          unless (all_events_info.signed_url)
            raise ApiReturnMissingElementError, "signed_url missing from api return of all events"
          end
          unless (all_rsvps_info.signed_url)
            raise ApiReturnMissingElementError, "signed_url missing from api return of all rsvps"
          end
          ret.all_events_api_url = all_events_info.signed_url
          ret.all_rsvps_api_url = all_rsvps_info.signed_url

          #Iterate through the events returned by the API and
          #create add the details to the RemoteEventAPIDetail objs
          all_events_info.each do |event_info|
            curr_event_id = event_info.id.to_s.to_sym
            puts("curr_event_id = '#{curr_event_id}'. class_name = '#{curr_event_id.class.name}'")
            curr_api_detail = api_detail_hash[curr_event_id]
            if (curr_api_detail)
              curr_api_detail.event_url = event_info.event_url
              curr_api_detail.title = event_info.name
              event_group = event_info.group
              puts "event_group = #{event_group.inspect}"
              if (event_group)
                curr_api_detail.group_name = event_group["name"]
                curr_api_detail.group_url = construct_meetup_group_url(event_group["urlname"])
              end
              curr_api_detail.description = event_info.description
              if (event_info.time) 
                puts "event_info.time = #{event_info.time}"
                #loc_start_date = Time.at(event_info.time)
                curr_api_detail.start_date = event_info.time
                puts "start_date = #{curr_api_detail.start_date}"
                if (time_delta = event_info.duration)
                  puts "event_info.duration = #{event_info.duration}"
                  puts "time_delta = '#{time_delta}'"
                  start_date_in_ms = event_info.time.strftime('%Q').to_i
                  loc_end_time = Time.at((start_date_in_ms + time_delta)/1000)
                  puts "loc_end_time = '#{loc_end_time}'"
                  curr_api_detail.end_date = loc_end_time
                  puts "end_date = #{curr_api_detail.end_date}"
                end
              end
            else
              puts("ERROR! Did not have an api_detail for '#{curr_event_id}'")
            end
          end

          #add the remote_event_api_details in the order given in id_arr
          id_arr.each do |id_s|
            curr_api_detail = api_detail_hash[id_s.to_s.to_sym]
            if (curr_api_detail)
              ret.remote_event_api_details << curr_api_detail
            else
              puts("ERROR! Did not have an api_detail for '#{curr_event_id}'")
            end
          end
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