# frozen_string_literal: true

module GobiertoCore
  def self.table_name_prefix
    'gcore_'
  end

  def self.classes_with_custom_fields
    [User]
  end

  class << self
    alias_method :cache_base_key, :table_name_prefix
  end
end
