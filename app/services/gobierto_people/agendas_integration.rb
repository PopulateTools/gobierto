module GobiertoPeople
  class AgendasIntegration

    def self.sync_all_agendas
      Site.with_agendas_integration_enabled.each do |site|
        calendar_integration = site.calendar_integration

        site.people.with_calendar_configuration.each { |person| calendar_integration.sync_person_events(person) }
      end
    end

  end
end
