module GobiertoPeople
  module MicrosoftExchange
    class CalendarIntegration

      attr_reader :person, :site

      SYNC_RANGE = {
        start_date: DateTime.now - 2.months,
        end_date:   DateTime.now + 1.year
      }

      TARGET_CALENDAR_NAME = 'gobierto'

      def self.sync_person_events(person)
        new(person).sync
      end

      def self.person_calendar_configuration_class
        ::GobiertoPeople::PersonMicrosoftExchangeCalendarConfiguration
      end

      def initialize(person)
        @person = person
        @site = person.site
        configuration = GobiertoPeople::PersonMicrosoftExchangeCalendarConfiguration.find_by(person_id: person.id)

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
        Rails.logger.info "[SYNC AGENDAS] Syncing Microsoft Exchange events for #{person.name} (id: #{person.id})"

        root_folder   = Exchanger::Folder.find(:calendar)
        target_folder = root_folder.folders.find { |folder| folder.display_name == TARGET_CALENDAR_NAME }

        if target_folder.nil?
          Rails.logger.info "[SYNC AGENDAS] Can't find '#{TARGET_CALENDAR_NAME}' calendar folder for #{person.name} (id: #{person.id})"
          return
        end

        calendar_items = target_folder.expanded_items(SYNC_RANGE)

        mark_unreceived_events_as_drafts(calendar_items)


        calendar_items.each do |item|
          next if is_private?(item)
          sync_event(item)
        end
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
          unreceived_external_ids = site.events
                                        .where(starts_at: SYNC_RANGE[:start_date]..SYNC_RANGE[:end_date])
                                        .where.not(external_id: nil)
                                        .where.not(external_id: received_external_ids)
                                        .update_all(state: GobiertoCalendars::Event.states[:pending])
        end
      end

    end
  end
end
