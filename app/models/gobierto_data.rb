# frozen_string_literal: true

module GobiertoData
  def self.table_name_prefix
    "gdata_"
  end

  def self.classes_with_custom_fields
    [GobiertoData::Dataset]
  end
end
