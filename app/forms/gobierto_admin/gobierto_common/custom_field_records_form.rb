# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class CustomFieldRecordsForm < BaseForm

      attr_accessor(
        :site_id,
        :item
      )

      delegate :persisted?, to: :item

      validates :site, presence: true

      def available_custom_fields
        site.custom_fields.sorted.where(class_name: item.class.name)
      end

      def custom_field_records
        @custom_field_records ||= available_custom_fields.map do |custom_field|
          ::GobiertoCommon::CustomFieldRecordDecorator.new(site.custom_field_records.find_or_initialize_by(item: item, custom_field: custom_field))
        end
      end

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
        site.custom_fields.pluck(:uid, :options).map do |uid, options|
          { uid: uid,
            max_width: 500,
            max_height: 500 }
        end
      end

      def custom_field_records=(values)
        @custom_field_records ||= begin
                                     values["custom_records"].to_h.map do |uid, value|
                                       record = site.custom_field_records.find_or_initialize_by(
                                         custom_field: ::GobiertoCommon::CustomField.find_by(uid: uid, class_name: item.class.name),
                                         item: item
                                       )
                                       if record.custom_field_id == value["custom_field_id"].to_i
                                         if record.custom_field.image?
                                           record.value = upload_file(uid, value) if value["value"].present?
                                         else
                                           record.value = value["value"]
                                         end
                                       end
                                       ::GobiertoCommon::CustomFieldRecordDecorator.new(record)
                                     end
                                   end
      end

      def save
        save_custom_fields if valid?
      end

      private

      def site
        @site ||= Site.find_by(id: site_id || item.try(:site_id))
      end

      def upload_file(uid, value)
        return nil unless value["value"].present?

        GobiertoAdmin::FileUploadService.new(
          site: site,
          collection: item.model_name.collection,
          attribute_name: uid,
          file: value["value"],
          x: value["crop"]["x"].to_f,
          y: value["crop"]["y"].to_f,
          w: value["crop"]["w"].to_f,
          h: value["crop"]["h"].to_f
        ).upload!
      end

      def save_custom_fields
        custom_field_records.each do |record|
          unless record.save
            promote_errors(record.errors)
            return false
          end
        end
        custom_field_records
      end
    end
  end
end
