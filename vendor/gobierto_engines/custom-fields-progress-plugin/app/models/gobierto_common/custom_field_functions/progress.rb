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

      calculation_custom_fields = uids.map { |uid| site.custom_fields.find_by!(uid: uid) }

      calculation_records = GobiertoCommon::CustomFieldRecord.where(item: record.item, custom_field: calculation_custom_fields)
      progress_items = calculation_records.map { |record| record.functions(version: @version).progress(options) }.compact

      return if progress_items.blank?

      progress_items.instance_eval { sum / size.to_f }

    rescue StandardError => e
      Appsignal.send_error(e)

      nil
    end

    def update_progress!
      current_progress = progress
      record.value = { record.custom_field.uid => current_progress }.to_json
      record.callback_update = true

      record.save!

      return unless record.item&.has_attribute? :progress

      record.item.update_column(:progress, current_progress&.*(100))
    end

  end
end
