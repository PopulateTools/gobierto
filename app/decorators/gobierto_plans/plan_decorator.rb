# frozen_string_literal: true

module GobiertoPlans
  class PlanDecorator < BaseDecorator
    def initialize(plan)
      @object = plan
    end

    def level_keys
      @level_keys ||= begin
                        level_keys = configuration_data&.select { |k| k =~ /level\d\z/ } || {}

                        (0..levels + 1).each do |level|
                          next if level_keys["level#{level}"].present?

                          element_type = level <= levels ? "category" : "project"
                          level_keys["level#{level}"] = default_translations(element_type, level + 1)
                        end

                        level_keys
                      end
    end

    def to_s
      text = ""
      # "5 cats, 43 subcats, 151 subsubcats, 161 nodes"
      if levels&.positive?
        (0..(levels)).each do |level|
          category_size = categories.where(level: level).size
          text += category_size.to_s + " " + level_key(category_size, level) + ", "
        end
      end

      if nodes.any?
        text += node_size.to_s + " " + level_key(node_size, levels + 1)
      end

      text
    end

    def level_key(level_size, level)
      return configuration_data["level#{level}"][level_size == 1 ? "one" : "other"][I18n.locale.to_s] if configuration_data.present? && configuration_data.has_key?("level#{level}")

      element_type = level <= levels ? "category" : "project"
      I18n.t("gobierto_admin.gobierto_plans.plans.import_csv.defaults.#{element_type}", count: level_size, level: level + 1)
    end

    private

    def default_translations(element_type, level)
      {
        "one" => site.configuration.available_locales.inject({}) do |translations, locale|
          translations.update(
            locale => I18n.t("gobierto_admin.gobierto_plans.plans.import_csv.defaults.#{element_type}", count: 1, level: level + 1)
          )
        end,
        "other" => site.configuration.available_locales.inject({}) do |translations, locale|
          translations.update(
            locale => I18n.t("gobierto_admin.gobierto_plans.plans.import_csv.defaults.#{element_type}", count: 2, level: level + 1)
          )
        end
      }
    end
  end
end
