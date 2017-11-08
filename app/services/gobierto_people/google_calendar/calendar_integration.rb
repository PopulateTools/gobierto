require 'tempfile'
require 'fileutils'

module GobiertoPeople
  module GoogleCalendar
    class CalendarIntegration
      CLIENT_SECRETS_PATH = Rails.root.join('config', 'google_calendar_integration_client_secret.json')
      USERNAME = 'default'
      SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

      def self.person_calendar_configuration_class
        ::GobiertoPeople::PersonGoogleCalendarConfiguration
      end

      def self.sync_person_events(person)
        new(person).sync!
      end

      def initialize(person)
        @person = person
        @configuration = GobiertoPeople::PersonGoogleCalendarConfiguration.find_by person_id: person.id

        @service = Google::Apis::CalendarV3::CalendarService.new
        @service.client_options.application_name = person.site.name
        @service.authorization = authorize(person)
      end

      def sync!
        set_google_calendar_id!

        service.list_calendar_lists(max_results: 100).items.each do |calendar|
          if configuration.calendars.present? && configuration.calendars.include?(calendar.id)
            sync_calendar_events(calendar)
          end
        end
      end

      def calendars
        @calendars ||= service.list_calendar_lists(max_results: 100).items
      end

      private

      attr_reader :person, :configuration, :service

      def set_google_calendar_id!
        if @configuration.google_calendar_id.nil?
          @configuration.google_calendar_id = calendars.select{ |c| c.primary? }.first.id
          @configuration.save
        end
      end

      def sync_calendar_events( calendar)
        response = service.list_events(calendar.id, always_include_email: true, time_min: Time.now.iso8601)
        response.items.each do |event|
          next if is_private?(event) || (!is_creator?(event) && !is_attendee?(event))

          if is_recurring?(event)
            service.list_event_instances(calendar.id, event.id).items.each_with_index do |event, i|
              sync_event(event, i)
            end
          else
            sync_event(event)
          end
        end
      end

      def is_private?(event)
        %w( private confidential ).include?(event.visibility)
      end

      def is_creator?(event)
        event.creator.email == configuration.google_calendar_id
      end

      def is_attendee?(event)
        Array(event.attendees).any?{ |a| a.email == configuration.google_calendar_id }
      end

      def is_recurring?(event)
        event.recurrence.present?
      end

      def event_attendees(event)
        return [] if event.attendees.nil?

        event.attendees.map do |attendee_attributes|
          {
            name: attendee_attributes.display_name,
            email: attendee_attributes.email,
            person: (attendee_attributes.self? ? person : nil)
          }
        end
      end

      def sync_event(event, i = nil)
        person_event_params = {
          site_id: person.site_id,
          external_id: event.id,
          title: event.summary,
          description: event.description,
          starts_at: event.start.date_time || DateTime.parse(event.start.date),
          ends_at: event.end.date_time || DateTime.parse(event.end.date),
          state: GobiertoCalendars::Event.states[:published],
          attendees: event_attendees(event),
          notify: i.nil? || i == 0
        }
        if is_creator?(event)
          person_event_params.merge!(person_id: person.id)
        else
          person_event_params.merge!(person_id: 0)
        end

        if event.location.present?
          person_event_params.merge!(locations_attributes: {"0" => {name: event.location} })
        else
          person_event_params.merge!(locations_attributes: {"0" => {"_destroy" => "1" }})
        end

        event = GobiertoPeople::PersonEventForm.new(person_event_params)
        event.save
      end

      def authorize(person)
        file = Tempfile.new [person.site_id, person.id].join('_')
        file.write @configuration.google_calendar_credentials
        file.rewind

        client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
        token_store = Google::Auth::Stores::FileTokenStore.new(file: file.path)
        authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
        authorizer.get_credentials(USERNAME)
      end
    end
  end
end
