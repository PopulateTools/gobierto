# frozen_string_literal: true

module GobiertoPlans
  class SdgDecorator < BaseDecorator
    def initialize(plan)
      @object = plan
    end

    def has_data?
      sdg_field.present?
    end

    def sdg_records
      return [] unless sdg_field.present?

      @sdg_records ||= sdg_field.records.where(item: nodes)
    end

    def sdgs_with_projects
      @sdgs_with_projects ||= sdg_records.map(&:value).flatten.uniq
    end

    def sdgs_distribution
      @sdgs_distribution ||= sdgs_with_projects.inject({}) do |distribution, sdg|
        distribution.update(
          sdg => nodes_query.filter(sdg_field => { "eq" => [sdg.id.to_s] })
        )
      end
    end

    private

    def sdg_field
      @sdg_field ||= site.custom_fields.find_by(uid: configuration_data["sdg_uid"])
    end

    def nodes_query
      @nodes_query ||= GobiertoCommon::CustomFieldsQuery.new(relation: nodes, custom_fields: site.custom_fields.where(id: sdg_field.id))
    end
  end
end
