# frozen_string_literal: true

module GobiertoInvestments
  def self.table_name_prefix
    "ginv_"
  end

  def self.classes_with_custom_fields
    [GobiertoInvestments::Project]
  end

  def self.doc_url
    "https://gobierto.readme.io/docs/inversiones"
  end

  class << self
    alias_method :cache_base_key, :table_name_prefix
  end
end
