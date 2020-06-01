# frozen_string_literal: true

module GobiertoCommon::CustomFieldFunctions
  class Indicator < Base
    delegate :latest_value_reached_row, to: :class

    def self.latest_indicators(rows)
      rows.group_by(&:id).map { |_id, rows_group| latest_value_reached_row(rows_group) }.compact
    end

    def self.latest_value_reached_row(rows)
      versioned_rows = rows.select { |row| row.value_reached.present? && row.date.present? }

      if versioned_rows.count < 2
        versioned_rows.first
      else
        versioned_rows.max_by(&:date)
      end
    end

    def indicators(_options = {})
      data
    end

    def latest_indicators(_options = {})
      data.group_by(&:id).map { |_id, rows| latest_value_reached_row(rows) }.compact
    end

    private

    def indicator_has_vocabulary?
      @indicator_has_vocabulary ||= configuration.plugin_configuration["columns"].find { |col| col["id"] == "indicator" }&.dig("type") == "vocabulary"
    end

    def data
      @data ||= begin
                  resources = value.is_a?(Array) ? value : value.dig(custom_field.uid) || []

                  resources.map do |resource|
                    indicator = indicator_term(resource)
                    next unless indicator.present?

                    OpenStruct.new(
                      id: indicator_has_vocabulary? ? indicator.id : indicator.name,
                      indicator: indicator,
                      objective: resource["objective"],
                      value_reached: resource["value_reached"],
                      date_string: resource["date"] || "",
                      date: parse_date(resource["date"] || "")
                    )
                  end.compact
                end
    end

    def indicator_term(resource)
      return ::GobiertoCommon::Term.find_by(id: resource["indicator"]) if indicator_has_vocabulary?

      ::GobiertoCommon::Term.new(
        name: resource["indicator"],
        description: resource["description"]
      )
    end

    def parse_date(date, fallback = nil)
      Date.strptime(date, "%Y-%m")
    rescue ArgumentError
      begin
        Date.strptime(date, "%Y")
      rescue ArgumentError
        fallback
      end
    end
  end
end
