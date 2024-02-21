# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class CustomFieldRecordsForm < ::GobiertoCommon::CustomFieldRecordsForm

      def has_localized_records?
        custom_field_records.any?(&:has_localized_value?)
      end

      def localized_custom_field_records
        custom_field_records.select(&:has_localized_value?)
      end

      def not_localized_custom_field_records
        custom_field_records.reject(&:has_localized_value?)
      end

      def image_fields_options
        site.custom_fields.pluck(:uid).map do |uid|
          { uid: uid,
            max_width: 500,
            max_height: 500 }
        end
      end

      def custom_field_records=(values)
        @custom_field_records = values["custom_records"].to_h.map do |uid, value|
          record = site.custom_field_records.find_or_initialize_by(
            custom_field: site.custom_fields.find_by(uid: uid, class_name: item.class.name),
            item: item
          )
          if record.custom_field_id == value["custom_field_id"].to_i
            record.value = if record.custom_field.configuration.multiple
                             extract_multiple_values(value, record)
                           else
                             extract_single_value(value, record, default_value: record.value)
                           end
          end
          ::GobiertoCommon::CustomFieldRecordDecorator.new(record)
        end
      end

      def extract_multiple_values(value, record)
        new_values = value.values.map do |item|
          extract_single_value(item, record)
        end.compact
        current_values = record.value
        current_values = [current_values] unless current_values.is_a? Array
        values = (value["existing"]&.values || []) & current_values
        values + new_values
      end

      def extract_single_value(value, record, default_value: nil)
        if record.custom_field.image?
          return default_value unless value["value"].present?

          upload_file(record.custom_field.uid, value)
        else
          value["value"]
        end
      end

      private

      def upload_file(uid, value)
        return nil unless value["value"].present?

        GobiertoAdmin::FileUploadService.new(
          site: site,
          collection: item.model_name.collection,
          attribute_name: uid,
          file: value["value"]
        ).upload!
      end

    end
  end
end
