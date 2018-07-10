# frozen_string_literal: true

module GobiertoPlans
  module PlanHelper
    def level_name_pluralize(number_of_elements, translation_key)
      count = number_of_elements == 1 ? "one" : "other"

      "#{number_of_elements} #{translation_key[count][I18n.locale.to_s]}"
    end
  end
end
