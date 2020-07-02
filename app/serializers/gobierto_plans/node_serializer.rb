# frozen_string_literal: true

module GobiertoPlans
  class NodeSerializer < BaseSerializer
    include ::GobiertoCommon::Versionable
    include ::GobiertoCommon::HasCustomFieldsAttributes

    attributes :id, :name, :category_id, :progress, :starts_at, :ends_at, :status_id, :position, :external_id

    def category_id
      instance_options.dig(:category_ids, object.id) ||
      object.categories.find_by(gplan_categories_nodes: { category_id: instance_options[:plan].categories })&.id
    end

    def custom_fields
      instance_options[:custom_fields]
    end
  end
end
