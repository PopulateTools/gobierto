# frozen_string_literal: true

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
      if instance.is_a?(GobiertoPlans::Plan) # GobiertoPlans
        ::GobiertoPlans::Node.node_custom_fields(instance, item).sorted
      else
        site.custom_fields.sorted.where(class_name: item.class.name, instance_type: instance_type_options, instance_id: instance_id_options)
      end
    end

    def custom_field_records
      @custom_field_records ||= available_custom_fields.map do |custom_field|
        record = site.custom_field_records.find_or_initialize_by(item: item, custom_field: custom_field)
        record = record.versions[version_index].reify if version_index && !(record.versions.count + version_index).negative? && record.versions[version_index].reify.present?

        ::GobiertoCommon::CustomFieldRecordDecorator.new(record)
      end
    end

    def custom_field_records=(attributes)
      @custom_field_records = attributes.to_h.map do |attribute, value|
        custom_field = site.custom_fields.find_by(uid: attribute)

        next unless custom_field.present?

        record = site.custom_field_records.find_or_initialize_by(
          custom_field: custom_field,
          item: item
        )
        record.value = single_value(value, record)
        ::GobiertoCommon::CustomFieldRecordDecorator.new(record)
      end.compact
    end

    def save
      return unless valid?

      save_result = save_custom_fields
      if save_result.present? && item.respond_to?(:pg_search_document)
        item.reset_serialized_version if versioned?
        item.update_pg_search_document
      end

      save_result
    end

    def single_value(value, record, default_value: nil)
      record.custom_field.plugin? ? { record.custom_field.uid => (value || default_value) } : (value || default_value)
    end

    def changed?
      custom_field_records.any? { |custom_field| version_changed?(custom_field) }
    end

    def associated_vocabularies
      available_custom_fields.select(&:has_vocabulary?).map(&:vocabulary).compact
    end

    private

    def version_changed?(custom_field)
      return true unless ::GobiertoCommon::CustomFieldRecord.exists?(custom_field.id)

      if with_version && version_index.present?
        (
          custom_field.versions[version_index]&.reify ||
          ::GobiertoCommon::CustomFieldRecord.find(custom_field.id)
        ).slice(*attributes_for_new_version) != custom_field.slice(*attributes_for_new_version)
      else
        custom_field.changed?
      end
    end

    def versioned?
      @versioned ||= item.respond_to?(:paper_trail)
    end

    def instance_type_options
      return [nil] unless instance

      [nil, instance.class.name]
    end

    def instance_id_options
      return [nil] unless instance

      [nil, instance.id]
    end

    def site
      @site ||= Site.find_by(id: site_id || item.try(:site_id))
    end

    def callback_update
      versioned? && !with_version
    end

    def save_custom_fields
      return custom_field_records if with_version && !force_new_version && !changed?

      custom_field_records.each do |record|
        record.item_has_versions = with_version
        record.callback_update = callback_update

        save_success = with_version && force_new_version && !record.changed? ? record.paper_trail.save_with_version : record.save
        unless save_success
          promote_errors(record.errors)
          return false
        end
      end
      custom_field_records
    end

    def attributes_for_new_version
      %w(item_type item_id custom_field_id payload)
    end
  end
end
