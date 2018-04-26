# frozen_string_literal: true
require "#{Rails.root}/lib/ibm_notes/api"

module GobiertoPeople
  module IbmNotes
    class CalendarIntegration

      include CalendarServiceHelpers

      attr_reader :person, :calendar_configuration

      def self.recurring_event?(event_data)
        event_data['links'].present? && has_instances_link?(event_data['links'])
      end

      def self.has_instances_link?(links_data)
        links_data.each do |element|
          return true if (element['rel'].present? && element['rel'] == 'instances')
        end
        false
      end

      def initialize(person)
        @person = person
        @calendar_configuration = find_calendar_configuration
      end

      def integration_log_preffix
        "[IBM Notes]"
      end

      def sync!
        log_synchronization_start(person_id: person.id, person_name: person.name)

        person_event_urls = get_person_events_urls
        processing_url_index = 0

        received_events_ids = person_event_urls.map do |event_url|
          log_message "Processing URL (#{processing_url_index += 1}/#{person_event_urls.size}): #{event_url}"

          response_data = ::IbmNotes::Api.get_event(request_params_for_event_request(event_url))

          next if response_data.nil? || response_data['events'].blank?

          event_data = response_data['events'][0]

          process_event(event_data, event_url)
        end.compact.flatten

        log_available_events_count(received_events_ids.size)

        person.events.upcoming.synchronized.each do |event|
          unless received_events_ids.include?(event.external_id)
            event.pending!
          end
        end
      rescue ::IbmNotes::InvalidCredentials
        log_message("Invalid credentials for site")
      rescue ::IbmNotes::ServiceUnavailable
        log_message("IBM Notes calendar API is down")
      rescue ::JSON::ParserError
        log_message("JSON parser error")
      ensure
        log_synchronization_end(person_id: person.id, person_name: person.name)
      end

      def sync_event(ibm_notes_event)
        filter_result = GobiertoCalendars::FilteringRuleApplier.filter({
          title: ibm_notes_event.title,
          description: (ibm_notes_event.description unless calendar_configuration.without_description == "1"),
        }, calendar_configuration.filtering_rules)

        state = filter_result.action == GobiertoCalendars::FilteringRuleApplier::CREATE_PENDING ?
          GobiertoCalendars::Event.states[:pending] :
          GobiertoCalendars::Event.states[:published]

        locations_attributes = if ibm_notes_event.location.present?
                                 { name: ibm_notes_event.location }
                               else
                                 { "_destroy" => "1" }
                               end

        person_event_params = {
          site_id: ibm_notes_event.person.site.id,
          external_id: ibm_notes_event.id,
          person_id: ibm_notes_event.person.id,
          title: filter_result.event_attributes[:title],
          description: filter_result.event_attributes[:description],
          starts_at: ibm_notes_event.starts_at,
          ends_at: ibm_notes_event.ends_at,
          state: state,
          attendees: ibm_notes_event.attendees,
          locations_attributes: {"0" => locations_attributes },
          notify: true
        }

        event_form = GobiertoPeople::PersonEventForm.new(person_event_params)

        if filter_result.action == GobiertoCalendars::FilteringRuleApplier::REMOVE
          log_destroy_rule
          event_form.destroy
          nil
        else
          if !event_form.save then log_invalid_event(event_form.errors.messages) end
          event_form.external_id
        end
      end

      private

      def get_person_events_urls
        response_events = ::IbmNotes::Api.get_person_events(request_params_for_events)

        # some APIs return an empty array when no events instead of a hash
        if response_events && response_events.is_a?(Hash) && response_events['events'].present?
          response_events['events'].map { |event_data| event_data['href'] }
        else
          []
        end
      end

      def event_instances_urls(recurrent_event_href)
        response_data = ::IbmNotes::Api.get_recurrent_event_instances(request_params_for_event_request(recurrent_event_href))

        if response_data && response_data["instances"].present?
          event_instances_urls = response_data["instances"].map { |instance_data| instance_data["href"] }
          event_instances_urls.select { |url| GobiertoCalendars.sync_range.cover?(Time.zone.parse(url.split("/").last)) }
        else
          []
        end
      end

      def request_params_for_events
        {
          endpoint: calendar_configuration.ibm_notes_url.concat("?since=#{sync_range_start}"),
          username: calendar_configuration.ibm_notes_usr,
          password: plain_text_password
        }
      end

      def request_params_for_event_request(event_path)
        uri = URI.parse(calendar_configuration.ibm_notes_url)
        {
          endpoint: "#{uri.scheme}://#{uri.host}#{event_path}",
          username: calendar_configuration.ibm_notes_usr,
          password: plain_text_password
        }
      end

      def process_event(event_data, event_url)
        processed_events_ids = []

        if self.class.recurring_event?(event_data)
          instances_urls = event_instances_urls(event_url)

          instances_urls.each do |event_url|
            response_event = ::IbmNotes::Api.get_event(request_params_for_event_request(event_url))

            if response_event && response_event['events'].present?
              ibm_event = ::IbmNotes::PersonEvent.new(person, response_event['events'][0])
              processed_events_ids << sync_event(ibm_event)
            end
          end
        else
          ibm_event = ::IbmNotes::PersonEvent.new(person, event_data)
          processed_events_ids << sync_event(ibm_event)
        end

        processed_events_ids
      end

      def sync_range_start
        GobiertoCalendars.sync_range_start.iso8601.split('+')[0].concat('Z')
      end

      def plain_text_password
        SecretAttribute.decrypt(calendar_configuration.ibm_notes_pwd)
      end

      def find_calendar_configuration
        ::GobiertoCalendars::IbmNotesCalendarConfiguration.find_by(collection_id: person.calendar.id)
      end

    end
  end
end