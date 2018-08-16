# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class NodeSerializer < ActiveModel::Serializer
      attributes(
        :id,
        :categories_hierarchy,
        :name_translations,
        :progress,
        :status_translations,
        :starts_at,
        :ends_at,
        :options,
        :options_json,
        :created_at,
        :updated_at
      )

      def category
        @category ||= base_categories_relation.where(cnt: { node_id: object.id }).first
      end

      def options_json
        JSON.pretty_generate(object.options) unless object.options.blank?
      end

      def categories_hierarchy
        @categories_hierarchy ||= begin
                                  [category].tap do |hierarchy|
                                    while (parent = hierarchy.first.parent_term).present?
                                      hierarchy.unshift(parent)
                                    end
                                  end.pluck(:id)
                                end
      end

      private

      def base_categories_relation
        (instance_options[:plan] || object).categories.joins(Arel.sql("JOIN #{ categories_nodes_table } AS cnt ON cnt.category_id = #{ categories_table }.id"))
      end

      def categories_nodes_table
        ::GobiertoPlans::CategoriesNode.table_name
      end

      def categories_table
        ::GobiertoCommon::Term.table_name
      end
    end
  end
end
