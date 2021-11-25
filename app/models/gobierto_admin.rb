module GobiertoAdmin
  def self.table_name_prefix
    "admin_"
  end

  class << self
    alias_method :cache_base_key, :table_name_prefix
  end
end
