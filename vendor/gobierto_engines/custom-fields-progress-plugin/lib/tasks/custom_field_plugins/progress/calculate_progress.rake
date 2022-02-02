# frozen_string_literal: true

namespace :custom_field_plugins do
  namespace :progress do
    desc "Calculate total progress of plugin custom field records of type progress based on the other configured fields"
    task calculate_progress: :environment do

      sites_list = []
      progress_custom_fields_with_plan = GobiertoCommon::CustomField.with_plugin_type("progress").where(instance_type: "GobiertoPlans::Plan")
      plans_with_progress = GobiertoPlans::Plan.where(id: progress_custom_fields_with_plan.select(:instance_id))

      progress_custom_fields_with_plan.each do |custom_field|
        next if custom_field.instance.blank?

        sites_list << custom_field.site unless sites_list.include?(custom_field.site) || custom_field.instance.nodes.empty?

        custom_field.instance.nodes.each do |node|
          custom_field.records.find_or_initialize_by(item: node).functions.update_progress!
        end
      end

      GobiertoPlans::Plan.where.not(id: plans_with_progress).each do |plan|
        free_progress_custom_fields = plan.site.custom_fields.with_plugin_type("progress").where(instance: nil)
        sites_list << plan.site unless sites_list.include?(plan.site) || free_progress_custom_fields.empty?

        free_progress_custom_fields.each do |custom_field|
          plan.nodes.each do |node|
            custom_field.records.find_or_initialize_by(item: node).functions.update_progress!
          end
        end
      end

      plans_with_progress.each(&:touch)

      sites_list.each do |site|
        Publishers::GobiertoPlansProjectActivity.broadcast_event("progresses_updated", ip: "127.0.0.1", subject: site, site_id: site.id)
      end

    end
  end
end
