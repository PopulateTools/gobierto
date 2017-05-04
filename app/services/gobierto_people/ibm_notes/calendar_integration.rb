module GobiertoPeople
  module IbmNotes
    class CalendarIntegration

      def self.sync_person_events(person)
        events_collection_hrefs = get_person_events_collection_hrefs(person)
        received_events_external_ids = []

        events_collection_hrefs.each do |href|
          response_data = ::IbmNotes::Api.get_event_by_href(request_params_for_href_request(person, href))

          if response_data && response_data['events'].present?
            event_data = response_data['events'][0]
          else
            next
          end

          if recurring_event?(event_data)
            instances_hrefs = get_person_event_instances_hrefs(person, href)

            instances_hrefs.each do |href|
              response_event = ::IbmNotes::Api.get_event_by_href(request_params_for_href_request(person, href))

              if response_event && response_event['events'].present?
                received_events_external_ids << create_and_sync_ibm_notes_event(person, response_event['events'][0])
              end
            end
          else # instancia de evento recurrente o evento no recurrente
            received_events_external_ids << create_and_sync_ibm_notes_event(person, event_data)
          end
        end
        
        person.events.synchronized_events.each do |event|
          unless received_events_external_ids.include?(event.external_id)
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

      def self.create_and_sync_ibm_notes_event(person, event_data)
        event = ::IbmNotes::PersonEvent.new(person, event_data)
        sync_event(event)
        event.external_id
      end

      def self.sync_event(ibm_notes_event)
        if ibm_notes_event.first_synchronization?
          create_gobierto_event(ibm_notes_event)
        else
          update_gobierto_event(ibm_notes_event) if ibm_notes_event.gobierto_event_outdated?
          update_gobierto_event_location(ibm_notes_event) if ibm_notes_event.gobierto_event_location_outdated?
        end
      end

      def self.person_calendar_configuration_class
        ::GobiertoPeople::PersonIbmNotesCalendarConfiguration
      end

      private

      def self.get_person_events_collection_hrefs(person)
        response_events = ::IbmNotes::Api.get_person_events_collection(request_params(person))

        if response_events && response_events['events'].present?
          response_events['events'].map { |event_data| event_data['href'] }
        else
          []
        end
      end

      def self.get_person_event_instances_hrefs(person, href)
        response_data = ::IbmNotes::Api.get_recurrent_event_instances(request_params_for_href_request(person, href))

        if response_data && response_data['instances'].present?
          response_data['instances'].map { |instance_data| instance_data['href'] }
        else
          []
        end
      end

      def self.recurring_event?(event_data)
        event_data['links'].present? && has_instances_link?(event_data['links'])
      end

      def self.has_instances_link?(links_data)
        links_data.each do |element|
          return true if (element['rel'].present? && element['rel'] == 'instances')
        end
        false
      end

      def self.request_params(person)
        gobierto_people_settings = person.site.gobierto_people_settings
        {
          endpoint: person_calendar_endpoint(person),
          username: gobierto_people_settings.ibm_notes_usr,
          password: gobierto_people_settings.ibm_notes_pwd
        }
      end

      def self.request_params_for_href_request(person, href)
        gobierto_people_settings = person.site.gobierto_people_settings
        uri = URI.parse person_calendar_endpoint(person)
        {
          endpoint: "#{uri.scheme}://#{uri.host}#{href}",
          username: gobierto_people_settings.ibm_notes_usr,
          password: gobierto_people_settings.ibm_notes_pwd
        }
      end

      def self.person_calendar_endpoint(person)
        person_calendar_configuration = PersonIbmNotesCalendarConfiguration.find_by(person_id: person.id)
        person_calendar_configuration.endpoint
      end

      def self.create_gobierto_event(ibm_notes_event)
        event = GobiertoPeople::PersonEvent.create!(
          external_id: ibm_notes_event.external_id,
          title: ibm_notes_event.title,
          starts_at: ibm_notes_event.starts_at,
          ends_at: ibm_notes_event.ends_at,
          person: ibm_notes_event.person,
          state: GobiertoPeople::PersonEvent.states[:published]
        )

        create_event_location(event, ibm_notes_event.location) if ibm_notes_event.location.present?
      end

      def self.update_gobierto_event(ibm_notes_event)
        ibm_notes_event.gobierto_event.update_attributes!(
          title: ibm_notes_event.title,
          starts_at: ibm_notes_event.starts_at,
          ends_at: ibm_notes_event.ends_at,
          state: ibm_notes_event.state
        )
      end

      def self.update_gobierto_event_location(ibm_notes_event)
        gobierto_event = ibm_notes_event.gobierto_event

        if ibm_notes_event.location_previously_synced?
          gobierto_event.locations.first.update_attributes!(name: ibm_notes_event.location)
        elsif ibm_notes_event.location_has_been_added?
          create_event_location(gobierto_event, ibm_notes_event.location)
        elsif ibm_notes_event.location_has_been_removed?
          gobierto_event.locations.destroy_all
        end
      end

      def self.create_event_location(event, location_name)
        GobiertoPeople::PersonEventLocation.create!(
          person_event: event,
          name: location_name
        )
      end

    end
  end
end
