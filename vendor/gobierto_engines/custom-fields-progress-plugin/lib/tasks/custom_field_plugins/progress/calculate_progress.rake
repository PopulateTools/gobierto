# frozen_string_literal: true

namespace :custom_field_plugins do
  namespace :progress do
    desc "Calculate total progress of plugin custom field records of type progress based on the other configured fields"
    task calculate_progress: :environment do

      GobiertoCommon::CustomField.with_plugin_type("progress").where.not(instance: nil).each do |custom_field|
        custom_field.instance.nodes.each do |node|
          custom_field.records.find_or_initialize_by(item: node).functions.update_progress!
        end
      end

      GobiertoPlans::Plan.where.not(id: GobiertoCommon::CustomField.with_plugin_type("progress").where.not(instance: nil)).each do |plan|
        plan.site.custom_fields.with_plugin_type("progress").where(instance: nil).each do |custom_field|
          plan.nodes.each do |node|
            custom_field.records.find_or_initialize_by(item: node).functions.update_progress!
          end
        end
      end

      GobiertoPlans::Plan.all.each(&:touch)
    end
  end
end
