namespace :gobierto_people do
  desc "Synchronizes sites agendas with selected calendar provider"
  task sync_agendas: :environment do
    GobiertoPeople::AgendasIntegration.sync_all_agendas
  end
end
