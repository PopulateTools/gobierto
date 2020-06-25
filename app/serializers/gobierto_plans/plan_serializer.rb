# frozen_string_literal: true

module GobiertoPlans
  class PlanSerializer < BaseSerializer
    include Rails.application.routes.url_helpers

    cache key: "plan"
    belongs_to :plan_type, unless: :exclude_relationships?
    attributes :id, :slug, :title, :introduction, :year, :visibility_level, :configuration_data, :css, :footer
    attribute :categories_vocabulary_terms, unless: :exclude_relationships? do
      ActiveModelSerializers::SerializableResource.new(object.categories_vocabulary.terms.sorted, **vocabularies_serialization_options).as_json
    end

    attribute :statuses_vocabulary_terms, unless: :exclude_relationships? do
      ActiveModelSerializers::SerializableResource.new(object.statuses_vocabulary.terms.sorted, **vocabularies_serialization_options).as_json
    end

    attribute :links, unless: :exclude_links? do
      {
        show: gobierto_plans_api_v1_plan_path(object),
        meta: meta_gobierto_plans_api_v1_plan_path(object)
      }
    end
  end
end
