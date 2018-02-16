# frozen_string_literal: true
#
module GobiertoPeople
  module MicrosoftExchange
    class CalendarIntegration

      include CalendarServiceHelpers

      attr_reader :person, :site, :configuration

      TARGET_CALENDAR_NAME = 'gobierto'

      def self.sync_person_events(person)
        new(person).sync
      end

      def sync
        log_synchronization_start(person_id: person.id, person_name: person.name)

        calendar_items = get_calendar_items || []

        log_available_events_count(calendar_items.size)

        mark_unreceived_events_as_drafts(calendar_items)

        Array(calendar_items).each do |item|
          sync_event(item)
        end
      rescue ::Errno::EADDRNOTAVAIL, ::SocketError, ::ArgumentError, ::Addressable::URI::InvalidURIError
        log_message("Invalid endpoint address for #{person.name} (id: #{person.id}): #{Exchanger.config.endpoint}")
      rescue ::HTTPClient::ConnectTimeoutError
        log_message("Timeout error for #{person.name} (id: #{person.id}): #{Exchanger.config.endpoint}")
      ensure
        log_synchronization_end(person_id: person.id, person_name: person.name)
      end

      private

      def initialize(person)
        @person = person
        @site = person.site
        @configuration = ::GobiertoCalendars::MicrosoftExchangeCalendarConfiguration.find_by(collection_id: person.calendar.id)

        Exchanger.configure do |config|
          config.endpoint = configuration.microsoft_exchange_url
          config.username = configuration.microsoft_exchange_usr
          config.password = ::SecretAttribute.decrypt(configuration.microsoft_exchange_pwd)
          config.debug    = false
          config.insecure_ssl = true
          config.ssl_version  = :TLSv1
        end
      end

      def get_calendar_items
        root_folder = Exchanger::Folder.find(:calendar)

        log_missing_folder_error('root') and return [] if root_folder.nil?

        target_folder = root_folder.folders.find { |folder| folder.display_name == TARGET_CALENDAR_NAME }

        log_missing_folder_error(TARGET_CALENDAR_NAME) and return [] if target_folder.nil?

        # summarized events does not include events description
        sumarized_events = target_folder.expanded_items(start_date: GobiertoCalendars.sync_range_start, end_date: GobiertoCalendars.sync_range_end)

        if sumarized_events.present?
          items_ids = sumarized_events.map { |i| i.id }
          ::Exchanger::GetItem.run(item_ids: items_ids).items
        else
          nil
        end
      end

      def sync_event(event)
        filter_result = GobiertoCalendars::FilteringRuleApplier.filter({
          title: event.subject,
          description: (event.body.text unless configuration.without_description == "1")
        }, configuration.filtering_rules)

        filter_result.action = GobiertoCalendars::FilteringRuleApplier::REMOVE if is_private?(event)

        state = (filter_result.action == GobiertoCalendars::FilteringRuleApplier::CREATE_PENDING) ?
          GobiertoCalendars::Event.states[:pending] :
          GobiertoCalendars::Event.states[:published]

        event_params = {
          starts_at: event.start,
          ends_at: event.end,
          state: state,
          external_id: event.id,
          title: filter_result.event_attributes[:title],
          description: filter_result.event_attributes[:description],
          site_id: site.id,
          person_id: person.id
        }

        if event.location.present?
          event_params.merge!(locations_attributes: { "0" => { name: event.location } })
        else
          event_params.merge!(locations_attributes: { "0" => { "_destroy" => "1" } })
        end

        event_form = GobiertoPeople::PersonEventForm.new(event_params)

        if filter_result.action == GobiertoCalendars::FilteringRuleApplier::REMOVE
          log_destroy_rule
          event_form.destroy
        elsif !event_form.save
          log_invalid_event(event_form.errors.messages)
        end
      end

      def is_private?(calendar_item)
        %w( Private ).include?(calendar_item.sensitivity)
      end

      def mark_unreceived_events_as_drafts(calendar_items)
        if calendar_items && calendar_items.any?
          received_external_ids = calendar_items.map(&:id)
          person.events
                .where(starts_at: GobiertoCalendars.sync_range)
                .where.not(external_id: nil)
                .where.not(external_id: received_external_ids)
                .update_all(state: GobiertoCalendars::Event.states[:pending])
        end
      end

      def log_missing_folder_error(folder_name)
        log_message("Can't find #{folder_name} calendar folder for #{person.name} (id: #{person.id}). Wrong username, password or endpoint?")
      end

    end
  end
end
