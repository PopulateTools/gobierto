# frozen_string_literal: true

module GobiertoCommon
  def self.classes_with_custom_fields
    [GobiertoCms::Page]
  end

  def self.cache_base_key
    "gcommon_"
  end
end
