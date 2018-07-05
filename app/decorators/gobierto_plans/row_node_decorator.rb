# frozen_string_literal: true

module GobiertoPlans
  class RowNodeDecorator < BaseDecorator
    def initialize(row, plan)
      @object = row
      @plan = plan
    end

    def locale
      @locale ||= @plan.site.configuration.default_locale
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

    def node_data
      @node_data ||= prefixed_row_data(/\ANode\./)
    end

    def prefixed_row_data(prefix)
      object.headers.select { |h| prefix.match(h) }.map do |h|
        [h.sub(prefix, "").downcase, object[h]]
      end.to_h
    end

    def node_attributes
      { "name_#{locale}": node_data["title"],
        "status_#{locale}": node_data["status"],
        "progress": node_data["progress"].to_f,
        starts_at: Time.zone.parse(node_data["start"]),
        ends_at: Time.zone.parse(node_data["end"]),
        options: node_data.except("title", "status", "start", "end", "progress") }
    end

    def node
      @node ||= begin
                  category = categories.last
                  (category.nodes.with_name_translation(node_data["title"], locale).first || category.nodes.new).tap do |node|
                    node.assign_attributes node_attributes
                    node.categories << category unless node.categories.include?(category)
                  end
                end
    end
  end
end
