# frozen_string_literal: true

module GobiertoInvestments
  def self.table_name_prefix
    "ginv_"
  end

  def self.classes_with_custom_fields
    [GobiertoInvestments::Project]
  end
end
