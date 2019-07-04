# frozen_string_literal: true

module GobiertoPlans
  class CategoryTermDecorator < BaseTermDecorator
    include ActionView::Helpers::NumberHelper

    attr_reader :cached_attributes

    def initialize(term, options = {})
      @object = term
      @vocabulary = options[:vocabulary]
      @plan = options[:plan]
      @site = options[:site]
      @with_published_versions = options[:with_published_versions]
      @cached_attributes = options[:cached_attributes]
    end

    def categories
      terms
    end

    def site
      @site ||= vocabulary.site
    end

    def plan
      @plan ||= site.plans.find_by_vocabulary_id(vocabulary.id)
    end

    def with_published_versions?
      @with_published_versions.present?
    end

    def uid
      @uid ||= begin
                 category = object
                 indices = []
                 while category.present?
                   same_level_ids = plan.categories.where(level: category.level, term_id: category.term_id).sorted.pluck(:id)
                   indices.unshift(same_level_ids.index(category.id))
                   category = category.parent_term
                 end
                 indices.join(".")
               end
    end

    def progress
      return if nodes_count.zero?

      @progress ||= if with_published_versions?
                      versioned_progresses.compact.instance_eval do
                        break nil if blank?

                        sum / size.to_f
                      end
                    else
                      descending_nodes.average(:progress).to_f
                    end
    end

    def progress_percentage
      return if nodes_count.zero?

      @progress_percentage ||= number_to_percentage(progress, precision: 1, strip_insignificant_zeros: true)
    end

    def nodes_count
      @nodes_count ||= descending_nodes.count
    end

    def parent_id
      @parent_id ||= object.term_id
    end

    def nodes
      base_relation.where(gplan_categories_nodes: { category_id: object.id })
    end

    def nodes_data
      CollectionDecorator.new(
        nodes.published,
        decorator: GobiertoPlans::ProjectDecorator,
        opts: { plan: plan, site: site }
      ).map.with_index do |node, index|
        { id: node.id,
          uid: uid + "." + index.to_s,
          type: "node",
          level: level + 1,
          attributes: {
            title: node.at_current_version.name_translations,
            parent_id: id,
            progress: node.at_current_version.progress,
            starts_at: node.at_current_version.starts_at,
            ends_at: node.at_current_version.ends_at,
            status: node.at_current_version.status&.name_translations,
            options: node.at_current_version.options,
            plugins_data: node_plugins_data(plan, node),
            custom_field_records: node_custom_field_records(node)
          },
          children: [] }
      end
    end

    def has_dependent_resources?
      plan.present? && progress.present?
    end

    def self.decorated_values?
      true
    end

    def self.decorated_header_template
      "header"
    end

    def self.decorated_values_template
      "values"
    end

    def self.decorated_resources_template
      "resources"
    end

    def decorated_values
      { items: nodes_count, progress: progress_percentage }
    end

    def decorated_resources
      return if nodes_count.zero?

      { projects: nodes, plan: plan }
    end

    protected

    def descending_nodes
      @descending_nodes ||= base_relation.where("gplan_categories_nodes.category_id IN (#{self.class.tree_sql_for(self)})")
    end

    def base_relation
      @base_relation ||= with_published_versions? ? plan.nodes.published : plan.nodes
    end

    def vocabulary
      @vocabulary ||= object.vocabulary
    end

    private

    def node_plugins_data(_plan, _node)
      {}
    end

    def node_custom_field_records(node)
      ::GobiertoPlans::Node.node_custom_field_records(plan, node).map do |record|
        next if record.custom_field.field_type == "plugin"

        {
          value: record.value_string,
          raw_value: record.raw_value,
          custom_field_name_translations: record.custom_field.name_translations,
          custom_field_field_type: record.custom_field.field_type
        }
      end.compact
    end

    def versioned_progresses
      if cached_attributes&.has_key?(:progress)
        descending_nodes.map { |node| cached_attributes[:progress][node.id] }
      else
        CollectionDecorator.new(
          descending_nodes,
          decorator: GobiertoPlans::ProjectDecorator,
          opts: { plan: plan, site: site }
        ).map do |node|
          node.at_current_version.progress
        end
      end
    end

  end
end
