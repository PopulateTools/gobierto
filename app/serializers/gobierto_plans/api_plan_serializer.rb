# frozen_string_literal: true

module GobiertoPlans
  class ApiPlanSerializer < BaseSerializer
    attributes(
      :id,
      :slug,
      :title_translations,
      :introduction_translations,
      :configuration_data,
      :year,
      :visibility_level,
      :css,
      :footer_translations
    )

    belongs_to :plan_type, unless: :exclude_relationships?
    attribute :categories_vocabulary_terms, unless: :exclude_relationships? do
      if object.categories_vocabulary.present?
        serialize_terms(object.categories_vocabulary.terms.sorted)
      end
    end
    attribute :statuses_vocabulary_terms, unless: :exclude_relationships? do
      if object.statuses_vocabulary.present?
        serialize_terms(object.statuses_vocabulary.terms.sorted)
      end
    end
    attribute :projects, unless: :exclude_relationships?

    def projects
      return if object.nodes.blank?

      serialize_projects(object.nodes)
    end

    def serialize_projects(nodes_relation)
      ActiveModelSerializers::SerializableResource.new(
        nodes_relation,
        each_serializer: ::GobiertoPlans::ApiNodeSerializer,
        plan: object,
        # custom_fields: object.front_available_custom_fields,
        serialize_for_search_engine: true,
        include_draft: true
      ).as_json
    end
  end
end
