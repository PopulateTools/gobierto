# frozen_string_literal: true

module GobiertoPeople
  module MicrosoftExchange
    class CalendarIntegration

      include CalendarServiceHelpers

      attr_reader :person, :site, :configuration

      TARGET_CALENDAR_NAME = "gobierto"
      EVENTS_BATCH_SIZE = 20

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
        end
      end

      def integration_log_preffix
        "[Microsoft Exchange]"
      end

      def sync!
        log_synchronization_start(person_id: person.id, person_name: person.name)

        calendar_items = get_calendar_items || []

        log_available_events_count(calendar_items.size)

        mark_unreceived_events_as_drafts(calendar_items)

        Array(calendar_items).each do |item|
          sync_event(item)
        end
      rescue *auth_error_classes
        log_message("Invalid endpoint address for #{person.name} (id: #{person.id}): #{Exchanger.config.endpoint}")
        raise ::GobiertoCalendars::CalendarIntegration::AuthError
      rescue *timeout_error_classes
        log_message("Timeout error for #{person.name} (id: #{person.id}): #{Exchanger.config.endpoint}")
        raise ::GobiertoCalendars::CalendarIntegration::TimeoutError
      rescue ::GobiertoCalendars::CalendarIntegration::Error => e
        raise e
      ensure
        log_synchronization_end(person_id: person.id, person_name: person.name)
      end

      private

      def get_calendar_items
        root_folder = Exchanger::Folder.find(:calendar)

        folder_exists!(folder: root_folder, folder_name: "root")

        target_folder = root_folder.folders.find { |folder| folder.display_name == TARGET_CALENDAR_NAME }

        folder_exists!(folder: target_folder, folder_name: TARGET_CALENDAR_NAME)

        # summarized events does not include events description
        sumarized_events = target_folder.expanded_items(
          start_date: GobiertoCalendars.sync_range_start,
          end_date: GobiertoCalendars.sync_range_end
        )

        return nil unless sumarized_events.present?

        # request expanded events in batches to avoid timeout errors
        calendar_items = []
        batches = sumarized_events.map(&:id).each_slice(EVENTS_BATCH_SIZE).to_a
        requested_batches = 0

        batches.each do |batch|
          log_message("Requesting batch #{requested_batches += 1}/#{batches.size} for #{person.name} (id: #{person.id}).")
          calendar_items += Exchanger::GetItem.run(item_ids: batch).items
        end

        calendar_items
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
          person_id: person.id,
          integration_name: configuration.integration_name
        }

        event_params[:locations_attributes] = if event.location.present?
                                                { "0" => { name: event.location } }
                                              else
                                                { "0" => { "_destroy" => "1" } }
                                              end

        event_form = GobiertoPeople::CalendarSyncEventForm.new(event_params)

        if filter_result.action == GobiertoCalendars::FilteringRuleApplier::REMOVE
          log_destroy_rule(event_form.title)
          event_form.destroy
        elsif event_form.save
          log_saved_event(event_form)
        else
          log_invalid_event(event_form)
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

      def folder_exists!(params = {})
        return if params[:folder].present?

        log_message("Can't find #{params[:folder_name]} calendar folder for #{person.name} (id: #{person.id}). Wrong username, password or endpoint?")

        if params[:folder_name] == "root"
          raise ::GobiertoCalendars::CalendarIntegration::AuthError
        else
          raise ::GobiertoCalendars::CalendarIntegration::Error, "No se encuentra el calendario #{params[:folder_name]}"
        end
      end

      def auth_error_classes
        [
          ::Errno::EADDRNOTAVAIL,
          ::SocketError,
          ::ArgumentError,
          ::Addressable::URI::InvalidURIError,
          ::GobiertoCalendars::CalendarIntegration::AuthError
        ]
      end

      def timeout_error_classes
        [::HTTPClient::ConnectTimeoutError, ::HTTPClient::ReceiveTimeoutError]
      end

    end
  end
end
