# frozen_string_literal: true

require 'tempfile'
require 'fileutils'

module GobiertoPeople
  module GoogleCalendar
    class CalendarIntegration
      CLIENT_SECRETS_PATH = Rails.root.join('config', 'google_calendar_integration_client_secret.json')
      USERNAME = 'default'
      SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

      def self.sync_person_events(person)
        new(person).sync!
      end

      def sync!
        set_google_calendar_id!

        received_events_ids = []
        service.list_calendar_lists(max_results: 100).items.each do |calendar|
          if configuration.calendars.present? && configuration.calendars.include?(calendar.id)
            received_events_ids.concat sync_calendar_events(calendar)
          end
        end

        person.events.upcoming.synchronized.each do |event|
          unless received_events_ids.include?(event.external_id)
            event.pending!
          end
        end
      end

      def calendars
        @calendars ||= service.list_calendar_lists(max_results: 100).items
      end

      private

      def initialize(person)
        @person = person
        @configuration = GobiertoCalendars::GoogleCalendarConfiguration.find_by(collection_id: person.calendar.id)

        @service = Google::Apis::CalendarV3::CalendarService.new
        @service.client_options.application_name = person.site.name
        @service.authorization = authorize(person)
      end

      attr_reader :person, :configuration, :service

      def set_google_calendar_id!
        if @configuration.google_calendar_id.nil?
          @configuration.google_calendar_id = calendars.detect{ |c| c.primary? }.id
          @configuration.save
        end
      end

      def sync_calendar_events(calendar)
        received_events_ids = []

        response = service.list_events(calendar.id, always_include_email: true, time_min: GobiertoCalendars.sync_range_start.iso8601)
        response.items.each do |event|
          received_events_ids.push event.id
          next if is_private?(event)

          if is_recurring?(event)
            service.list_event_instances(calendar.id, event.id).items.each_with_index do |event, i|
              received_events_ids.push event.id
              sync_event(event, i)
            end
          else
            sync_event(event)
          end
        end

        received_events_ids
      end

      def is_private?(event)
        %w( private confidential ).include?(event.visibility)
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

      def sync_event(event, occurrence = nil)
        filter_result = GobiertoCalendars::FilteringRuleApplier.filter({
          title: event.summary,
          description: event.description
        }, configuration.filtering_rules)

        filter_result.action = GobiertoCalendars::FilteringRuleApplier::REMOVE if is_private?(event)

        state = (filter_result.action == GobiertoCalendars::FilteringRuleApplier::CREATE_PENDING) ?
          GobiertoCalendars::Event.states[:pending] :
          GobiertoCalendars::Event.states[:published]

        event_params = {
          site_id: person.site_id,
          external_id: event.id,
          person_id: person.id,
          title: filter_result.event_attributes[:title],
          description: filter_result.event_attributes[:description],
          starts_at: parse_date(event.start),
          ends_at: parse_date(event.end),
          state: state,
          attendees: event_attendees(event),
          notify: occurrence.nil? || occurrence == 0
        }

        if event.location.present?
          event_params.merge!(locations_attributes: {"0" => {name: event.location} })
        else
          event_params.merge!(locations_attributes: {"0" => {"_destroy" => "1" }})
        end

        if filter_result.action == GobiertoCalendars::FilteringRuleApplier::REMOVE
          GobiertoPeople::PersonEventForm.new(event_params).destroy
        else
          unless GobiertoPeople::PersonEventForm.new(event_params).save
            Rails.logger.info "[Google Calendar Integration] Invalid event: #{event_params}"
          end
        end
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

      def parse_date(time_attribute)
        if time_attribute
          time_attribute.date_time || DateTime.parse(time_attribute.date)
        end
      end
    end
  end
end
