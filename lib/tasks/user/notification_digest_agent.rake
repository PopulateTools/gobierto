namespace :user do
  namespace :notification_digest_agent do
    desc "Delivers hourly notification digests"
    task hourly: :environment do
      User::NotificationDigestAgent.new(:hourly).call
    end

    desc "Delivers daily notification digests"
    task daily: :environment do
      User::NotificationDigestAgent.new(:daily).call
    end

    desc "Delivers weekly notification digests"
    task weekly: :environment do
      User::NotificationDigestAgent.new(:weekly).call
    end
  end
end
