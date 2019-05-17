# frozen_string_literal: true

module GobiertoPlans
  def self.table_name_prefix
    'gplan_'
  end

  def self.doc_url
    "https://gobierto.readme.io/docs/planes"
  end

  def self.classes_with_custom_fields
    [GobiertoPlans::Node]
  end

  def self.classes_with_vocabularies
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
      "open_node": false
    }
JSON
  end
end
