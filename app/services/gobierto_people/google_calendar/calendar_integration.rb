# frozen_string_literal: true

require 'tempfile'
require 'fileutils'

module GobiertoPeople
  module GoogleCalendar
    class CalendarIntegration
      CLIENT_SECRETS_PATH = Rails.root.join("config", "google_calendar_integration_client_secret.json")
      USERNAME = "default"
      SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

      include CalendarServiceHelpers

      def initialize(person)
        @person = person
        @configuration = GobiertoCalendars::GoogleCalendarConfiguration.find_by(collection_id: person.calendar.id)

        @service = Google::Apis::CalendarV3::CalendarService.new
        @service.client_options.application_name = person.site.name
        @service.authorization = authorize(person)
        @received_event_ids = []
      end

      def integration_log_preffix
        "[Google Calendar]"
      end

      def sync!
        log_synchronization_start(person_id: person.id, person_name: person.name)

        set_google_calendar_id!
        import_events!
        delete_unreceived_events!
      end

      def calendars
        @calendars ||= service.list_calendar_lists(max_results: 100).items
      end

      private

      attr_reader :person, :configuration, :service, :received_event_ids

      def set_google_calendar_id!
        if @configuration.google_calendar_id.nil?
          @configuration.google_calendar_id = calendars.detect{ |c| c.primary? }.id
          @configuration.save
        end
      end

      def sync_calendar_events(calendar)
        log_message("Syncing calendar '#{calendar.summary}'")

        event_items = service.list_events(
          calendar.id,
          always_include_email: true,
          time_min: GobiertoCalendars.sync_range_start.iso8601,
          time_max: GobiertoCalendars.sync_range_end.iso8601,
          max_results: 2500,
          order_by: 'startTime',
          single_events: true
        ).items

        log_available_events_count(event_items.size)

        event_items.each do |event|

          next if is_private?(event)

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
          description: (event.description unless configuration.without_description == "1")
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
          notify: occurrence.nil? || occurrence == 0,
          integration_name: @configuration.integration_name
        }

        if event.location.present?
          event_params.merge!(locations_attributes: {"0" => {name: event.location} })
        else
          event_params.merge!(locations_attributes: {"0" => {"_destroy" => "1" }})
        end

        event_form = GobiertoPeople::CalendarSyncEventForm.new(event_params)

        if filter_result.action == GobiertoCalendars::FilteringRuleApplier::REMOVE
          log_destroy_rule(event_form.title)
          event_form.destroy
        else
          if event_form.save
            log_saved_event(event_form)
            received_event_ids.push(event.id)
          else
            log_invalid_event(event_form)
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
          time_attribute.date_time || time_attribute.date.to_datetime
        end
      end

      def import_events!
        available_calendars = service.list_calendar_lists(max_results: 100).items

        log_available_calendars_count(available_calendars.size)

        available_calendars.each do |calendar|
          if configuration.calendars.present? && configuration.calendars.include?(calendar.id)
            sync_calendar_events(calendar)
          end
        end

        log_synchronization_end(person_id: person.id, person_name: person.name)
      end

      def delete_unreceived_events!
        person.events.upcoming.synchronized.
          where.not(external_id: received_event_ids).
          each(&:pending!)
      end
    end
  end
end
