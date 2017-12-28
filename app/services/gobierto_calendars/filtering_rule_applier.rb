# frozen_string_literal: true

require_dependency "gobierto_calendars"

module GobiertoCalendars
  class FilteringRuleApplier
    CREATE = :create
    REMOVE = :remove
    CREATE_PENDING = :create_pending

    def self.filter(event_attributes, rules)
      return CREATE if rules.empty?

      rules_results = rules.map do |rule|
        rule.apply(event_attributes)
      end

      rules_results.delete_if{ |r| r == false }
      return REMOVE if rules_results.include?("ignore")
      return CREATE_PENDING if rules_results.include?("import_as_draft")
      return CREATE
    end
  end
end
