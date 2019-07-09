# frozen_string_literal: true

module GobiertoCommon::CustomFieldFunctions
  class Progress < Base

    def initialize(record, options = {})
      @version = options.delete(:version)

      super
    end

    def progress(options = {})
      uids = configuration.plugin_configuration["custom_field_uids"] || []

      return if uids.blank?

      calculation_custom_fields = site.custom_fields.find_by!(uid: uids)

      calculation_records = GobiertoCommon::CustomFieldRecord.where(item: record.item, custom_field: calculation_custom_fields)
      progress_items = calculation_records.map { |record| record.functions(version: @version).progress(options) }.compact

      return if progress_items.blank?

      progress_items.instance_eval { sum / size.to_f }

    rescue StandardError => e
      Rollbar.error(e)

      nil
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
