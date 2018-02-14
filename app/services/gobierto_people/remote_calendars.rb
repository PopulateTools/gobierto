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

        calendar_integration.sync_person_events(container)
        Publishers::AdminGobiertoCalendarsActivity.broadcast_event('calendars_synchronized', { ip: '127.0.0.1',  subject: container, site_id: site.id })
      end
    end

  end
end
