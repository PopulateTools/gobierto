# frozen_string_literal: true

module GobiertoPlans
  class ApiNodeSerializer < BaseSerializer
    include ::GobiertoCommon::Versionable

    attributes(
      :id,
      :external_id,
      :visibility_level,
      :moderation_stage,
      :name_translations,
      :category_id,
      :category_external_id,
      :status_id,
      :status_external_id,
      :progress,
      :starts_at,
      :ends_at,
      :position
    )

    def category
      @category ||= object.categories.find_by(gplan_categories_nodes: { category_id: instance_options[:plan].categories })
    end

    def category_id
      return if category.blank?

      category.id
    end

    def category_external_id
      return if category.blank?

      category.external_id
    end

    def status_external_id
      object.status&.external_id
    end
  end
end
