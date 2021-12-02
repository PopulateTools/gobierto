# frozen_string_literal: true

module GobiertoAttachments
  def self.table_name_prefix
    "ga_"
  end

  def self.permitted_attachable_types
    %w(GobiertoCms::Page GobiertoCalendars::Event GobiertoData::Dataset)
  end

  class << self
    alias_method :cache_base_key, :table_name_prefix
  end
end
