module GobiertoCalendars

  def self.table_name_prefix
    'gc_'
  end

  def self.searchable_models
    [ GobiertoCalendars::Event ]
  end

end
