# frozen_string_literal: true

module GobiertoPeople
  class RemoteCalendars

    def self.sync
      ::GobiertoCalendars::CalendarConfiguration.all.each do |calendar_configuration|
        collection = calendar_configuration.collection
        container = collection.container
        site = collection.site
        calendar_integration = collection.calendar_integration

        I18n.locale = site.configuration.default_locale

        begin
          calendar_integration.new(container).sync!
          Publishers::AdminGobiertoCalendarsActivity.broadcast_event('calendars_synchronized', { ip: '127.0.0.1',  subject: container, site_id: site.id })
        rescue GobiertoCalendars::CalendarIntegration::Error
          # Rescue this errors because they're just meant to display error feedback in the UI
        rescue StandardError => e
          Appsignal.send_error(e)
        end
      end
    end

  end
end
