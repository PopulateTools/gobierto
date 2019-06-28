# frozen_string_literal: true

namespace :custom_field_plugins do
  namespace :progress do
    desc "Calculate total progress of plugin custom field records of type progress based on the other configured fields"
    task calculate_progress: :environment do
      GobiertoCommon::CustomField.with_plugin_type("progress").each do |custom_field|
        custom_field.instance.nodes.each do |node|
          custom_field.records.find_or_initialize_by(item: node).functions.update_progress!
        end
      end

      GobiertoPlans::Plan.all.each(&:touch)
    end
  end
end
