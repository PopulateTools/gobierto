# frozen_string_literal: true

module GobiertoCms
  def self.table_name_prefix
    "gcms_"
  end

  def self.searchable_models
    [GobiertoCms::Page]
  end
end
