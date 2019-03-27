# frozen_string_literal: true

require_dependency "gobierto_calendars"

module GobiertoCalendars
  class FilteringRuleApplier
    CREATE = :create
    REMOVE = :remove
    CREATE_PENDING = :create_pending

    def self.filter(event_attributes, rules)
      filtering_result = GobiertoCalendars::FilteringResult.new event_attributes, CREATE
      return filtering_result if rules.empty?

      rules_results = rules.map do |rule|
        result = rule.apply(event_attributes)
        if rule.remove_filtering_text?
          filtering_result.event_attributes = rule.update_event_attributes(event_attributes)
        end
        result
      end

      rules_results.delete_if { |r| r == false }
      if rules_results.include?("ignore")
        filtering_result.action = REMOVE
      elsif rules_results.include?("import_as_draft")
        filtering_result.action = CREATE_PENDING
      end
      filtering_result
    end
  end
end
