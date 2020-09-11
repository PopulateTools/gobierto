# frozen_string_literal: true

module GobiertoPlans
  class SdgDecorator < BaseDecorator
    def initialize(plan)
      @object = plan
    end

    def has_data?
      sdg_field.present? && sdg_field.vocabulary.present?
    end

    def sdg_records
      return [] unless sdg_field.present?

      @sdg_records ||= sdg_field.records.where(item: nodes_relation)
    end

    def sdgs_with_projects
      @sdgs_with_projects ||= sdg_records.map(&:value).flatten.uniq
    end

    def sdgs_terms
      return unless sdg_field.vocabulary.present?

      @sdgs_terms ||= sdg_field.vocabulary.terms.where(level: 0).sorted
    end

    def projects_by_sdg(sdg)
      filter_value = sdg_field.configuration.vocabulary_type == "single_select" ? sdg.id.to_s : [sdg.id.to_s]

      CollectionDecorator.new(
        nodes_query.filter(sdg_field => { "eq" => filter_value }),
        decorator: GobiertoPlans::ProjectDecorator,
        opts: { plan: self }
      )
    end

    def sdg_percentage(sdg)
      return if sdgs_assignations.zero?

      ActionController::Base.helpers.number_with_precision((projects_by_sdg(sdg).count * 100.0) / sdgs_assignations, precision: 1) + "%"
    end

    def sdg_term(sdg_slug)
      sdgs_terms&.find_by(slug: sdg_slug)
    end

    def sdg_icon(sdg)
      return unless sdg.external_id.present?

      "ods/ods_goal_#{sdg.external_id.rjust(2, "0")}_#{I18n.locale}.png"
    end

    private

    def sdg_field
      return if configuration_data.blank?

      @sdg_field ||= site.custom_fields.find_by(uid: configuration_data["sdg_uid"])
    end

    def nodes_query
      @nodes_query ||= GobiertoCommon::CustomFieldsQuery.new(relation: nodes_relation, custom_fields: site.custom_fields.where(id: sdg_field.id))
    end

    def sdgs_assignations
      @sdgs_assignations ||= GobiertoCommon::CustomFieldRecord.where(custom_field: sdg_field, item: nodes_relation).map do |record|
        record.value.where(level: 0).count
      end.sum
    end

    def nodes_count
      @nodes_count ||= nodes_relation.count
    end

    def nodes_relation
      nodes.published
    end
  end
end
