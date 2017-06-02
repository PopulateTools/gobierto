namespace :gobierto_admin do
  desc "Regenerates admins preview token"
  task regenerate_preview_tokens: :environment do
    GobiertoAdmin::Admin.all.each do |admin|
      admin.send(:generate_preview_token)
      admin.save!
    end
  end
end
