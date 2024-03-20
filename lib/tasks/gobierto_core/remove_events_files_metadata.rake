# frozen_string_literal: true

namespace :gobierto_core do
  desc "Removes files metadata of admin API attachments controller events"
  task remove_events_files_metadata: :environment do
    Ahoy::Event.where("name LIKE ?", "%gobierto_admin/gobierto_attachments/api/attachments%").find_each do |event|
      next unless event.properties.dig("attachment", "file").present?

      properties = event.properties
      properties["attachment"] = properties["attachment"].except("file")
      event.update_attribute(:properties, properties)
    end
  end
end
