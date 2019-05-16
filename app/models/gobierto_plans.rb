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
end
