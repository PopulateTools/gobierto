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
      end

      def self.sync_event(ibm_notes_event)
        if ibm_notes_event.gobierto_event_outdated?
          update_gobierto_event(ibm_notes_event)
        elsif ibm_notes_event.public? && !ibm_notes_event.has_gobierto_event?
          create_gobierto_event(ibm_notes_event)
        end
      end

      def self.person_calendar_configuration_class
        ::GobiertoPeople::PersonIbmNotesCalendarConfiguration
      end

      private

      def self.request_params(person)
        site = person.site
        {
          endpoint: get_calendar_endpoint(person),
          username: GobiertoPeople::Setting.find_by(site_id: site.id, key: 'IBM_NOTES_ENDPOINT_USR').value,
          password: GobiertoPeople::Setting.find_by(site_id: site.id, key: 'IBM_NOTES_ENDPOINT_PWD').value
        }
      end

      def self.get_calendar_endpoint(person)
        person_calendar_configuration = PersonIbmNotesCalendarConfiguration.find_by_person_id(person.id)
        person_calendar_configuration.endpoint
      end

      def self.create_gobierto_event(ibm_notes_event)
        GobiertoPeople::PersonEvent.create!(
          external_id: ibm_notes_event.external_id,
          title: ibm_notes_event.title,
          starts_at: ibm_notes_event.starts_at,
          ends_at: ibm_notes_event.ends_at,
          person: ibm_notes_event.person,
          state: GobiertoPeople::PersonEvent.states[:published]
        )
      end

      def self.update_gobierto_event(ibm_notes_event)
        ibm_notes_event.gobierto_event.update_attributes!(
          title: ibm_notes_event.title,
          starts_at: ibm_notes_event.starts_at,
          ends_at: ibm_notes_event.ends_at,
          state: ibm_notes_event.state
        )
      end

    end
  end
end
