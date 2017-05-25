# frozen_string_literal: true

namespace :common do
  namespace :active_notifier do
    desc 'Actively seeks for events to notify'
    task daily: :environment do
      GobiertoCommon::ActiveNotifier::Daily.call
    end
  end
end
