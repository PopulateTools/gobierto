module GobiertoPeople
  module IbmNotes
    class CalendarIntegration

      def self.sync_person_events(person)
        received_events_ids = get_person_events_urls(person).map do |event_url|
          response_data = ::IbmNotes::Api.get_event(request_params_for_event_request(person, event_url))

          next if response_data.nil? || response_data['events'].blank?

          event_data = response_data['events'][0]

          process_event(event_data, event_url, person)
        end.compact.flatten

        person.events.upcoming.synchronized.each do |event|
          unless received_events_ids.include?(event.external_id)
            event.pending!
          end
        end
      rescue ::IbmNotes::InvalidCredentials
        Rails.logger.info "[#{person.site.name} calendar integration] Invalid credentials for site"
      rescue ::IbmNotes::ServiceUnavailable
        Rails.logger.info "[#{person.site.name} calendar integration] IBM Notes calendar API is down"
      rescue ::JSON::ParserError
        Rails.logger.info "[#{person.site.name} calendar integration] JSON parser error"
      end

      def self.person_calendar_configuration_class
        ::GobiertoCalendars::IbmNotesCalendarConfiguration
      end

      def self.sync_event(ibm_notes_event)
        locations_attributes = if ibm_notes_event.location.present?
                                 { name: ibm_notes_event.location }
                               else
                                 { "_destroy" => "1" }
                               end

        person_event_params = {
          site_id: ibm_notes_event.person.site.id,
          external_id: ibm_notes_event.id,
          person_id: ibm_notes_event.person.id,
          title: ibm_notes_event.title,
          description: ibm_notes_event.description,
          starts_at: ibm_notes_event.starts_at,
          ends_at: ibm_notes_event.ends_at,
          state: GobiertoCalendars::Event.states[:published],
          attendees: ibm_notes_event.attendees,
          locations_attributes: {"0" => locations_attributes },
          notify: true
        }

        event = GobiertoPeople::PersonEventForm.new(person_event_params)
        event.save
        event.external_id
      end

      # Private methods

      def self.create_and_sync_ibm_notes_event(person, event_data)
        event = ::IbmNotes::PersonEvent.new(person, event_data)
        created_event_external_id = sync_event(event)
        return created_event_external_id
      end
      private_class_method :create_and_sync_ibm_notes_event

      def self.process_event(event_data, event_url, person)
        processed_events_ids = []
        if recurring_event?(event_data)
          instances_urls = get_person_event_instances_urls(person, event_url)

          instances_urls.each do |event_url|
            response_event = ::IbmNotes::Api.get_event(request_params_for_event_request(person, event_url))

            if response_event && response_event['events'].present?
              processed_events_ids << create_and_sync_ibm_notes_event(person, response_event['events'][0])
            end
          end
        else
          processed_events_ids << create_and_sync_ibm_notes_event(person, event_data)
        end

        processed_events_ids
      end
      private_class_method :process_event

      def self.get_person_events_urls(person)
        response_events = ::IbmNotes::Api.get_person_events(request_params_for_events(person))

        # some APIs return an empty array when no events instead of a hash
        if response_events && response_events.is_a?(Hash) && response_events['events'].present?
          response_events['events'].map { |event_data| event_data['href'] }
        else
          []
        end
      end
      private_class_method :get_person_events_urls

      def self.get_person_event_instances_urls(person, href)
        response_data = ::IbmNotes::Api.get_recurrent_event_instances(request_params_for_event_request(person, href))

        if response_data && response_data['instances'].present?
          response_data['instances'].map { |instance_data| instance_data['href'] }
        else
          []
        end
      end
      private_class_method :get_person_event_instances_urls

      def self.recurring_event?(event_data)
        event_data['links'].present? && has_instances_link?(event_data['links'])
      end
      private_class_method :recurring_event?

      def self.has_instances_link?(links_data)
        links_data.each do |element|
          return true if (element['rel'].present? && element['rel'] == 'instances')
        end
        false
      end
      private_class_method :has_instances_link?

      def self.request_params_for_events(person)
        {
          endpoint: person_calendar_configuration(person).ibm_notes_url.concat("?since=#{sync_range_start}"),
          username: person_calendar_configuration(person).ibm_notes_usr,
          password: plain_text_password(person)
        }
      end
      private_class_method :request_params_for_events

      def self.request_params_for_event_request(person, event_path)
        uri = URI.parse person_calendar_configuration(person).ibm_notes_url

        {
          endpoint: "#{uri.scheme}://#{uri.host}#{event_path}",
          username: person_calendar_configuration(person).ibm_notes_usr,
          password: plain_text_password(person)
        }
      end
      private_class_method :request_params_for_event_request

      def self.plain_text_password(person)
        SecretAttribute.decrypt(person_calendar_configuration(person).ibm_notes_pwd)
      end
      private_class_method :plain_text_password

      def self.sync_range_start
        2.days.ago.iso8601.split('+')[0].concat('Z')
      end
      private_class_method :sync_range_start

      def self.person_calendar_configuration(person)
        person_calendar_configuration_class.find_by(collection_id: person.calendar.id)
      end
      private_class_method :person_calendar_configuration

    end
  end
end
