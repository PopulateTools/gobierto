# frozen_string_literal: true

module GobiertoPlans
  class NodeSerializer < BaseSerializer
    include ::GobiertoCommon::HasCustomFieldsAttributes

    cache key: "node"

    attributes :id, :name_translations, :category, :progress, :starts_at, :ends_at, :status_id, :published_version, :position, :external_id

    def category
      object.categories.find_by(gplan_categories_nodes: { category_id: instance_options[:plan].categories })
    end
  end
end
