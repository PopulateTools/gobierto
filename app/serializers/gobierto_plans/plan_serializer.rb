# frozen_string_literal: true

module GobiertoPlans
  class PlanSerializer < BaseSerializer
    include Rails.application.routes.url_helpers

    belongs_to :plan_type, unless: :exclude_relationships?
    attributes :id, :slug, :title, :introduction, :year, :visibility_level, :css, :footer
    attribute :configuration_data do
      object.configuration_data.except("fields_to_not_show_in_front")
    end
    attribute :categories_vocabulary_terms, unless: :exclude_relationships? do
      serialize_terms(object.categories_vocabulary.terms.sorted)
    end
    attribute :statuses_vocabulary_terms, unless: :exclude_relationships? do
      serialize_terms(object.statuses_vocabulary.terms.sorted)
    end

    attribute :links, unless: :exclude_links? do
      {
        show: gobierto_plans_api_v1_plan_path(object),
        meta: meta_gobierto_plans_api_v1_plan_path(object)
      }
    end
  end
end
