module GobiertoPeople
  class RemoteCalendars

    def self.sync
      Site.with_agendas_integration_enabled.each do |site|
        I18n.locale = site.configuration.default_locale
        calendar_integration = site.calendar_integration
        Rails.logger.info "[SYNC AGENDAS] Site: #{site.domain} Service: #{calendar_integration}"
        site.people.with_calendar_configuration.each do |person|
          calendar_integration.sync_person_events(person)
        end
      end
    end

  end
end
