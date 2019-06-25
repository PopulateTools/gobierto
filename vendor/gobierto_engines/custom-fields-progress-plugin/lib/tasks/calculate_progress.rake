# frozen_string_literal: true

namespace :gobierto_admin do
  desc "Calculate progress"
  task calculate_progress: :environment do
    GobiertoCommon::CustomField.with_plugin_type("progress").each do |custom_field|
      custom_field.instance.nodes.each do |node|
        progress_record = custom_field.records.find_or_initialize_by(item: node)
        progress_record.value = progress_record.functions.progress
        progress_record.save!
      end
    end
  end
end
