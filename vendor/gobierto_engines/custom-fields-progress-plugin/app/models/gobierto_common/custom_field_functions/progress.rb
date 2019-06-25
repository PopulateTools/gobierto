# frozen_string_literal: true

module GobiertoCommon::CustomFieldFunctions
  class Progress < Base
    def progress(options = {})
      ids = configuration.plugin_configuration["custom_field_ids"] || []
      uids = configuration.plugin_configuration["custom_field_uids"] || []

      return if ids.blank? && uids.blank?

      t = GobiertoCommon::CustomField.arel_table

      custom_fields = GobiertoCommon::CustomField.where(instance: custom_field.instance).where(
        t[:uid].in(uids).or(t[:id].in(ids))
      )

      records = GobiertoCommon::CustomFieldRecord.where(item: record.item, custom_field: custom_fields)
      progress_items = records.map { |record| record.functions.try(:progress, options) }.compact

      return if progress_items.blank?

      progress_items.instance_eval { sum / size.to_f }
    end

    def update_progress!
      current_progress = progress
      record.value = current_progress
      record.save!

      return unless record.item&.has_attribute? :progress

      record.item.update_column(:progress, current_progress&.*(100))
    end
  end
end
