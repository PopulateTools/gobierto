module GobiertoPeople
  module MicrosoftExchange
    class CalendarIntegration

      attr_reader :person, :site

      SYNC_RANGE = {
        start_date: DateTime.now - 2.days,
        end_date:   DateTime.now + 1.year
      }

      TARGET_CALENDAR_NAME = 'gobierto'

      def self.sync_person_events(person)
        new(person).sync
      end

      def self.person_calendar_configuration_class
        ::GobiertoCalendars::MicrosoftExchangeCalendarConfiguration
      end

      def initialize(person)
        @person = person
        @site = person.site
        configuration = ::GobiertoCalendars::MicrosoftExchangeCalendarConfiguration.find_by(collection_id: person.calendar.id)

        Exchanger.configure do |config|
          config.endpoint = configuration.microsoft_exchange_url
          config.username = configuration.microsoft_exchange_usr
          config.password = ::SecretAttribute.decrypt(configuration.microsoft_exchange_pwd)
          config.debug    = false
          config.insecure_ssl = true
          config.ssl_version  = :TLSv1
        end
      end

      def sync
        Rails.logger.info "#{log_preffix} Syncing events for #{person.name} (id: #{person.id})"

        root_folder = Exchanger::Folder.find(:calendar)

        log_missing_folder_error('root') and return if root_folder.nil?

        target_folder = root_folder.folders.find { |folder| folder.display_name == TARGET_CALENDAR_NAME }

        log_missing_folder_error(TARGET_CALENDAR_NAME) and return if target_folder.nil?

        calendar_items = target_folder.expanded_items(SYNC_RANGE)

        mark_unreceived_events_as_drafts(calendar_items)

        calendar_items.each do |item|
          next if is_private?(item)
          sync_event(item)
        end
      rescue ::Errno::EADDRNOTAVAIL, ::SocketError, ::ArgumentError, ::Addressable::URI::InvalidURIError
        Rails.logger.info "#{log_preffix} Invalid endpoint address for #{person.name} (id: #{person.id}): #{Exchanger.config.endpoint}"
      end

      def sync_event(item)
        event_params = {
          starts_at: item.start,
          ends_at: item.end,
          state: GobiertoCalendars::Event.states[:published],
          external_id: item.id,
          title: item.subject,
          site_id: site.id
        }

        event_params.merge!(person_id: person.id)

        if item.location.present?
          event_params.merge!(locations_attributes: { "0" => { name: item.location } })
        else
          event_params.merge!(locations_attributes: { "0" => { "_destroy" => "1" } })
        end

        event = GobiertoPeople::PersonEventForm.new(event_params)

        event.save
      end

      private

      def is_private?(calendar_item)
        %w( Private ).include?(calendar_item.sensitivity)
      end

      def mark_unreceived_events_as_drafts(calendar_items)
        if calendar_items.any?
          received_external_ids = calendar_items.map { |item| item.id }
          person.events
                .where(starts_at: SYNC_RANGE[:start_date]..SYNC_RANGE[:end_date])
                .where.not(external_id: nil)
                .where.not(external_id: received_external_ids)
                .update_all(state: GobiertoCalendars::Event.states[:pending])
        end
      end

      def log_preffix
        "[SYNC AGENDAS][MICROSOFT EXCHANGE]"
      end

      def log_missing_folder_error(folder_name)
        Rails.logger.info "#{log_preffix} Can't find #{folder_name} calendar folder for #{person.name} (id: #{person.id}). Wrong username, password or endpoint?"
      end

    end
  end
end
