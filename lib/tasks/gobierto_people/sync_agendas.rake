# frozen_string_literal: true

namespace :gobierto_people do
  desc 'Synchronizes sites agendas with selected calendar provider'
  task sync_agendas: :environment do
    GobiertoPeople::RemoteCalendars.sync
  end
end
