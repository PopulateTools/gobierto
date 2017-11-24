module GobiertoPeople
  class RemoteCalendars

    def self.sync
      ::GobiertoCalendars::CalendarConfiguration.all.each do |calendar_configuration|
        collection = calendar_configuration.collection
        container = collection.container
        site = collection.site
        calendar_integration = collection.calendar_integration

        I18n.locale = site.configuration.default_locale

        log_agenda_synchronization(collection, container, site)

        calendar_integration.sync_person_events(container)
      end
    end

    def self.log_agenda_synchronization(collection, container, site)
      message = %Q(
        ------------------------------ [SYNC CALENDAR] ------------------------------
        Site: #{site.domain}
        Integration service: #{collection.calendar_integration}
        Container class: #{container.class}
        Container identifier: #{collection.container_printable_name}
        -----------------------------------------------------------------------------
      )
      Rails.logger.info(message)
    end

  end
end
