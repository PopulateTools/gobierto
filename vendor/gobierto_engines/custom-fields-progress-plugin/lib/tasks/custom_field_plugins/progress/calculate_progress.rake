# frozen_string_literal: true

namespace :custom_field_plugins do
  namespace :progress do
    desc "Calculate total progress of plugin custom field records of type progress based on the other configured fields"
    task calculate_progress: :environment do

      sites_list = []

      GobiertoCommon::CustomField.with_plugin_type("progress").where.not(instance: nil).each do |custom_field|
        sites_list << custom_field.site unless sites_list.include?(custom_field.site) || custom_field.instance.nodes.empty?

        custom_field.instance.nodes.each do |node|
          custom_field.records.find_or_initialize_by(item: node).functions.update_progress!
        end
      end

      GobiertoPlans::Plan.where.not(id: GobiertoCommon::CustomField.with_plugin_type("progress").where.not(instance: nil)).each do |plan|
        custom_fields = plan.site.custom_fields.with_plugin_type("progress").where(instance: nil)
        sites_list << plan.site unless sites_list.include?(plan.site) || custom_fields.empty?

        custom_fields.each do |custom_field|
          plan.nodes.each do |node|
            custom_field.records.find_or_initialize_by(item: node).functions.update_progress!
          end
        end
      end

      GobiertoPlans::Plan.all.each(&:touch)

      sites_list.each do |site|
        Publishers::GobiertoPlansProjectActivity.broadcast_event("progresses_updated", ip: "127.0.0.1", subject: site, site_id: site.id)
      end

    end
  end
end
