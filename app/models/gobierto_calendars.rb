# frozen_string_literal: true

module GobiertoCalendars
  def self.table_name_prefix
    'gc_'
  end

  def self.searchable_models
    [ GobiertoCalendars::Event ]
  end

  def self.sync_range_start
    DateTime.now
  end

  def self.sync_range_end
    DateTime.now + 10.months
  end

  def self.sync_range
    sync_range_start..sync_range_end
  end

  def self.sync_range_start_ibm_notes
    DateTime.now - 2.days
  end

  def self.sync_range_end_ibm_notes
    DateTime.now + 10.months
  end

  def self.sync_range_ibm_notes
    sync_range_start_ibm_notes..sync_range_end_ibm_notes
  end

  class << self
    alias_method :cache_base_key, :table_name_prefix
  end
end
