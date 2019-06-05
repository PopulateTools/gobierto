# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class CustomFieldRecordsForm < BaseForm

      attr_accessor(
        :site_id,
        :item,
        :instance,
        :with_version,
        :force_new_version,
        :version_index
      )

      delegate :persisted?, to: :item

      validates :site, presence: true

      def available_custom_fields
        site.custom_fields.sorted.where(class_name: item.class.name)
      end

      def custom_field_records
        @custom_field_records ||= available_custom_fields.map do |custom_field|
          record = site.custom_field_records.find_or_initialize_by(item: item, custom_field: custom_field)
          record = record.versions[version_index].reify if version_index && !(record.versions.count + version_index).negative? && record.versions[version_index].reify.present?

          ::GobiertoCommon::CustomFieldRecordDecorator.new(record)
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

      def changed?
        custom_field_records.any?(&:changed?)
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
          record.item_has_versions = with_version

          save_success = with_version && force_new_version && !changed? ? record.paper_trail.save_with_version : record.save
          unless save_success
            promote_errors(record.errors)
            return false
          end
        end
        custom_field_records
      end
    end
  end
end
