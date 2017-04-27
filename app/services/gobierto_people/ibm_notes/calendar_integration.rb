module GobiertoPeople
  module IbmNotes
    class CalendarIntegration

      def self.sync_person_events(person)
        received_events = ::IbmNotes::Api.get_person_events(request_params(person))

        received_events.each do |event_hash|
          event = ::IbmNotes::PersonEvent.new(person, event_hash)
          sync_event(event)
        end

        received_events_ids = received_events.map { |event| event['id'] }

        person.events.synchronized_future_events.each do |future_event|
          unless received_events_ids.include?(future_event.external_id)
            future_event.pending!
          end
        end
      rescue ::IbmNotes::InvalidCredentials
        Rails.logger.info "[#{person.site.name} calendar integration] Invalid credentials for site"
      rescue ::IbmNotes::ServiceUnavailable
        Rails.logger.info "[#{person.site.name} calendar integration] IBM Notes calendar API is down"
      rescue ::JSON::ParserError
        Rails.logger.info "[#{person.site.name} calendar integration] JSON parser error"
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

      def self.request_params(person)
        gobierto_people_settings = person.site.gobierto_people_settings
        {
          endpoint: person_calendar_endpoint(person),
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
