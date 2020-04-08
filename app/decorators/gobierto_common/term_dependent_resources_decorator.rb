# frozen_string_literal: true

module GobiertoCommon
  class TermDependentResourcesDecorator < BaseDecorator
    def initialize(term)
      @object = term
    end

    def has_dependent_resources?
      dependent_associations.present? ||
        dependent_custom_fields_with_records.present? ||
        dependent_plans_categories.present?
    end

    def dependencies_list
      [
        dependent_associations_string,
        dependent_custom_fields_with_records_string,
        dependent_plans_categories_string
      ].map(&:presence).compact.join("\n")
    end

    private

    def dependent_associations_string
      dependent_associations.map do |association|
        "#{association.class_name}: Attribute #{association.attribute} on instances with ids #{association.ids.join(", ")}"
      end.join("\n")
    end

    def dependent_custom_fields_with_records_string
      dependent_custom_fields_with_records.map do |custom_field|
        <<-TEXT
        #{custom_field.class_name}: CustomField with uid #{custom_field.uid} and name #{custom_field.name}
        #{" (on instance of #{custom_field.instance_type} with id #{custom_field.instance_id})" if custom_field.instance.present?}
        TEXT
      end.join("\n")
    end

    def dependent_plans_categories_string
      return unless dependent_plans_categories.present?

      "GobiertoPlans::Plan: Attribute category_ids on projects of plans with ids: #{dependent_plans_categories.pluck(:id).join(", ")}"
    end

    def dependent_associations
      @dependent_associations ||= enabled_classes_with_vocabularies.map do |klass|
        klass.vocabularies.keys.map do |association|
          foreign_key = klass.reflections[association.to_s].foreign_key
          next unless klass.where(foreign_key => id).exists?

          OpenStruct.new(
            class_name: klass.name,
            attribute: foreign_key,
            ids: klass.where(foreign_key => id).pluck(:id)
          )
        end.compact.presence
      end.compact.flatten
    end

    def dependent_plans_categories
      @dependent_plans_categories ||= site.plans.where(vocabulary_id: vocabulary_id).select do |plan|
        GobiertoPlans::CategoryTermDecorator.new(self, plan: plan).has_dependent_resources?
      end
    end

    def dependent_custom_fields_with_records
      @dependent_custom_fields_with_records ||= site.custom_fields.vocabulary_options.for_vocabulary(vocabulary).select do |custom_field|
        filter_value = custom_field.configuration.vocabulary_type == "single_select" ? id.to_s : [id.to_s]
        custom_field.records.where("payload @> ?", { custom_field.uid => filter_value }.to_json).exists?
      end
    end
  end
end
