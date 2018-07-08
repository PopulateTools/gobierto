# frozen_string_literal: true

module GobiertoPlans
  class RowNodeDecorator < BaseDecorator

    def initialize(object, options = {})
      if object.is_a? CSV::Row
        @object = object
        @plan = options[:plan]
      elsif object.is_a? Node
        @node = object
        @plan = @node.categories.first&.plan
        @category = node_category
        @object = CSV::Row.new(plan_csv_columns, node_csv_values)
      elsif object.is_a? Category
        @category = object
        @plan = @category.plan
        @node = Node.new
        @object = CSV::Row.new(plan_csv_columns, node_csv_values)
      end
    end

    def categories
      @categories ||= begin
                        level_names = object.headers.select { |h| /Level \d+/.match(h) }.sort_by { |h| h[/\d+/].to_i }
                        current_level = @plan
                        categories = []
                        level_names.each_with_index do |name, index|
                          current_level =
                            current_level.categories.with_name_translation(object[name], locale).where(level: index).first ||
                            current_level.categories.new(
                              "name_#{ locale }": object[name],
                              level: index,
                              plan: @plan
                            )
                          categories << current_level
                        end
                        categories
                      end
    end

    def node
      @node ||= begin
                  return nil if node_data["Title"].blank?
                  category = categories.last
                  (category.nodes.with_name_translation(node_data["Title"], locale).first || category.nodes.new).tap do |node|
                    node.assign_attributes node_attributes
                    node.categories << category unless node.categories.include?(category)
                  end
                end
    end

    protected

    def node_data
      @node_data ||= prefixed_row_data(/\ANode\./)
    end

    def prefixed_row_data(prefix)
      object.headers.select { |h| prefix.match(h) }.map do |h|
        [h.sub(prefix, ""), object[h]]
      end.to_h
    end

    def locale
      @locale ||= @plan.site.configuration.default_locale
    end

    def node_attributes
      attributes = node_mandatory_columns.invert.transform_values { |column| object[column] }
      attributes.merge(options: node_data.except("Title", "Status", "Start", "End", "Progress"))
    end

    def node_mandatory_columns
      @node_mandatory_columns ||= { "Node.Title" => :"name_#{ locale }",
                                    "Node.Status" => :"status_#{ locale }",
                                    "Node.Progress" => :progress,
                                    "Node.Start" => :starts_at,
                                    "Node.End" => :ends_at }
    end

    def plan_options_keys
      @plan_options_keys ||= @plan.nodes.map { |node| node.options.keys }.uniq.flatten.uniq
    end

    def plan_nodes_extra_columns
      plan_options_keys.map do |key|
        "Node.#{ key }"
      end
    end

    def plan_csv_columns
      plan_categories_range.map { |num| "Level #{ num }" } +
        node_mandatory_columns.keys +
        plan_nodes_extra_columns
    end

    def plan_categories_range
      @plan.categories.minimum(:level)..@plan.categories.maximum(:level)
    end

    def categories_hierarchy(category)
      categories = []
      while category.present?
        categories.unshift(category)
        category = category.parent_category
      end
      categories
    end

    def node_category
      @node.categories.where(level: @plan.categories.maximum(:level)).first
    end

    def node_mandatory_values
      node_mandatory_columns.map do |_, method|
        @node.send(method)
      end
    end

    def category_values
      categories_hierarchy(@category).map do |category|
        category.send(:"name_#{ @locale }")
      end
    end

    def node_extra_values
      plan_options_keys.map do |key|
        node.options && node.options[key]
      end
    end

    def node_csv_values
      category_values + node_mandatory_values + node_extra_values
    end
  end
end
