# frozen_string_literal: true

module GobiertoPlans
  def self.table_name_prefix
    'gplan_'
  end

  def self.doc_url
    "https://gobierto.readme.io/docs/planes"
  end

  def self.root_path(current_site)
    site_plans = GobiertoPlans::PlanType.site_plan_types_with_years(current_site)
    if site_plans.any?
      plan_type = site_plans.first

      Rails.application.routes.url_helpers.gobierto_plans_plan_path(slug: plan_type.slug, year: plan_type.max_year)
    else
      ""
    end
  end

  def self.classes_with_custom_fields
    [GobiertoPlans::Node]
  end

  def self.classes_with_custom_fields_at_instance_level
    [GobiertoPlans::Plan]
  end

  def self.classes_with_vocabularies
    [GobiertoPlans::Node]
  end

  def self.searchable_models
    [GobiertoPlans::Node]
  end

  def self.default_plans_configuration_data
    <<JSON
    {
      "level0": {
        "one": {
          "en": "axis",
          "ca": "eix",
          "es": "eje"
        },
        "other": {
          "en": "axes",
          "ca": "eixos",
          "es": "ejes"
        }
      },
      "level1": {
        "one": {
          "en": "line of activity",
          "ca": "línia d'actuació",
          "es": "línea de actuación"
        },
        "other": {
          "en": "lines of activity",
          "ca": "línies d'actuació",
          "es": "líneas de actuación"
        }
      },
      "level2": {
        "one": {
          "en": "activity",
          "ca": "actuació",
          "es": "actuación"
        },
        "other": {
          "en": "activities",
          "ca": "actuacions",
          "es": "actuaciones"
        }
      },
      "level3": {
        "one": {
          "en": "project/action",
          "ca": "projecte/acció",
          "es": "proyecto/acción"
        },
        "other": {
          "en": "projects/actions",
          "ca": "projectes/accions",
          "es": "proyectos/acciones"
        }
      },
      "level0_options": [],
      "show_table_header": false,
      "open_node": false,
      "hide_level0_counters": false,
      "sdg_uid": null,
      "fields_to_not_show_in_front": [],
      "show_empty_fields": false
    }
JSON
  end

  class << self
    alias_method :cache_base_key, :table_name_prefix
  end
end
