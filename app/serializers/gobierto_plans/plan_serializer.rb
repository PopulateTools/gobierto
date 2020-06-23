# frozen_string_literal: true

module GobiertoPlans
  class PlanSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    cache key: "plan"

    belongs_to :plan_type
    belongs_to :categories_vocabulary, class_name: "GobiertoCommon::Vocabulary", foreign_key: :vocabulary_id
    belongs_to :statuses_vocabulary, class_name: "GobiertoCommon::Vocabulary", foreign_key: :statuses_vocabulary_id
    attributes :id, :slug, :title, :introduction, :year, :visibility_level, :configuration_data, :css, :footer
  end
end
