# frozen_string_literal: true

require_dependency "gobierto_calendars"

module GobiertoCalendars
  class FilteringRule < ApplicationRecord

    belongs_to :calendar_configuration
    validates :value, presence: true

    enum field: { title: 0, description: 1 }, _suffix: true
    enum condition: { contains: 0, not_contains: 1, starts_with: 2, ends_with: 3, not_starts_with: 4 }, _suffix: true
    enum action: { ignore: 0, import_as_draft: 1, import: 2 }, _suffix: true

    def apply(event_attributes)
      event_value = event_attributes.symbolize_keys[field.to_sym]
      return "import" if event_value.nil?

      fullfills = case condition
        when "contains"
          event_value.include?(value)
        when "not_contains"
          !event_value.include?(value)
        when "starts_with"
          event_value.starts_with?(value)
        when "ends_with"
          event_value.ends_with?(value)
        when "not_starts_with"
          !event_value.starts_with?(value)
      end

      fullfills ? action : false
    end

    def update_event_attributes(event_attributes)
      event_attributes.symbolize_keys!
      event_attributes[field.to_sym] = event_attributes[field.to_sym].gsub(value, "").gsub(/\s+/, " ").strip if event_attributes[field.to_sym].present?
      event_attributes
    end
  end
end
