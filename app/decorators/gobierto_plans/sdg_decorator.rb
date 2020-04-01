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

      @sdg_records ||= sdg_field.records.where(item: nodes_relation)
    end

    def sdgs_with_projects
      @sdgs_with_projects ||= sdg_records.map(&:value).flatten.uniq
    end

    def sdgs_terms
      @sdgs_terms ||= sdg_field.vocabulary.terms.where(level: 0).sorted
    end

    def projects_by_sdg(sdg)
      nodes_query.filter(sdg_field => { "eq" => [sdg.id.to_s] })
    end

    def sdg_term(sdg_slug)
      sdgs_terms.find_by(slug: sdg_slug)
    end

    def sdg_icon(sdg)
      "ods/ods_goal_#{sdg.external_id.rjust(2, "0")}_#{I18n.locale}.png"
    end

    private

    def sdg_field
      @sdg_field ||= site.custom_fields.find_by(uid: configuration_data["sdg_uid"])
    end

    def nodes_query
      @nodes_query ||= GobiertoCommon::CustomFieldsQuery.new(relation: nodes_relation, custom_fields: site.custom_fields.where(id: sdg_field.id))
    end

    def nodes_relation
      nodes.published
    end
  end
end
