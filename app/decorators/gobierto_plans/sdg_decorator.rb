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

    def sdg_ids_with_projects
      @sdg_ids_with_projects ||= sdgs_transformed_values.values.map(&:values).flatten.uniq
    end

    def sdgs_transformed_values
      @sdgs_transformed_values ||= GobiertoCommon::CustomFieldsService.new(
        relation: nodes_relation,
        custom_fields: sdg_fields,
        site: site
      ).transformed_custom_field_record_values
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
      return if total_sdgs_root_level_assignations.zero?

      "#{ActionController::Base.helpers.number_with_precision((sdgs_root_level_distribution.count(sdg.id.to_s) * 100.0) / total_sdgs_root_level_assignations, precision: 1)}%"
    end

    def sdg_term(sdg_slug)
      sdgs_terms&.find_by(slug: sdg_slug)
    end

    def sdg_icon(sdg)
      return unless sdg.external_id.present?

      "ods/ods_goal_#{sdg.external_id.rjust(2, "0")}_#{I18n.locale}.png"
    end

    def sdg_fields
      return site.custom_fields.none if configuration_data.blank?

      @sdg_fields ||= if configuration_data.blank?
                        site.custom_fields.none
                      else
                        site.custom_fields.where(uid: configuration_data["sdg_uid"])
                      end
    end

    private

    def sdg_field
      return if configuration_data.blank?

      @sdg_field ||= site.custom_fields.find_by(uid: configuration_data["sdg_uid"])
    end

    def nodes_query
      @nodes_query ||= GobiertoCommon::CustomFieldsQuery.new(relation: nodes_relation, custom_fields: site.custom_fields.where(id: sdg_field.id))
    end

    def total_sdgs_root_level_assignations
      @total_sdgs_root_level_assignations ||= sdgs_root_level_distribution.count
    end

    def sdgs_root_level_distribution
      @sdgs_root_level_distribution ||= begin
                                          root_level_ids = sdgs_terms.pluck(:id).map(&:to_s)
                                          sdgs_transformed_values.transform_values do |payload|
                                            payload.values.flatten.select { |sdg_id| root_level_ids.include?(sdg_id) }
                                          end
                                        end.values.flatten
    end

    def nodes_count
      @nodes_count ||= nodes_relation.count
    end

    def nodes_relation
      nodes.published
    end
  end
end
