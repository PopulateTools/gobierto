# frozen_string_literal: true

module GobiertoDashboards
  def self.table_name_prefix
    "gdb_"
  end

  class << self
    alias_method :cache_base_key, :table_name_prefix
  end
end
