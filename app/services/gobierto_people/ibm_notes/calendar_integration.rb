module GobiertoPeople
  module IbmNotes
    class CalendarIntegration

      def self.sync_person_events(person)
        received_events_ids = get_person_events_urls(person).map do |event_url|
          response_data = ::IbmNotes::Api.get_event(request_params_for_event_request(person, event_url))

          next if response_data.nil? || response_data['events'].blank?

          event_data = response_data['events'][0]

          process_event(event_data, event_url, person)
        end.compact

        person.events.synchronized_events.each do |event|
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
        ::GobiertoPeople::PersonIbmNotesCalendarConfiguration
      end

      def self.sync_event(ibm_notes_event)
        locations_attributes = if ibm_notes_event.location.present?
                                 { name: ibm_notes_event.location }
                               else
                                 { "_destroy" => "1" }
                               end

        person_event_params = {
          external_id: ibm_notes_event.id,
          person_id: ibm_notes_event.person.id,
          title: ibm_notes_event.title,
          starts_at: ibm_notes_event.starts_at,
          ends_at: ibm_notes_event.ends_at,
          state: GobiertoPeople::PersonEvent.states[:published],
          locations_attributes: {"0" => locations_attributes }
        }

        GobiertoPeople::PersonEventForm.new(person_event_params).save
      end

      # Private methods

      def self.create_and_sync_ibm_notes_event(person, event_data)
        event = ::IbmNotes::PersonEvent.new(person, event_data)
        sync_event(event)
        event.id
      end
      private_class_method :create_and_sync_ibm_notes_event

      def self.process_event(event_data, event_url, person)
        if recurring_event?(event_data)
          instances_urls = get_person_event_instances_urls(person, event_url)

          instances_urls.each do |event_url|
            response_event = ::IbmNotes::Api.get_event(request_params_for_event_request(person, event_url))

            if response_event && response_event['events'].present?
              create_and_sync_ibm_notes_event(person, response_event['events'][0])
            end
          end
        else
          create_and_sync_ibm_notes_event(person, event_data)
        end
      end
      private_class_method :process_event

      def self.get_person_events_urls(person)
        response_events = ::IbmNotes::Api.get_person_events(request_params_for_events(person))

        if response_events && response_events['events'].present?
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
        gobierto_people_settings = person.site.gobierto_people_settings

        {
          endpoint: person_calendar_endpoint(person),
          username: gobierto_people_settings.ibm_notes_usr,
          password: gobierto_people_settings.ibm_notes_pwd
        }
      end
      private_class_method :request_params_for_events

      def self.request_params_for_event_request(person, event_path)
        gobierto_people_settings = person.site.gobierto_people_settings
        uri = URI.parse person_calendar_endpoint(person)

        {
          endpoint: "#{uri.scheme}://#{uri.host}#{event_path}",
          username: gobierto_people_settings.ibm_notes_usr,
          password: gobierto_people_settings.ibm_notes_pwd
        }
      end
      private_class_method :request_params_for_event_request

      def self.person_calendar_endpoint(person)
        PersonIbmNotesCalendarConfiguration.find_by(person_id: person.id).endpoint
      end
      private_class_method :person_calendar_endpoint

    end
  end
end
