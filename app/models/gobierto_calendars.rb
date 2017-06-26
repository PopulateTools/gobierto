module GobiertoCalendars
  def self.table_name_prefix
    'gobierto_calendars_'
  end
  def self.searchable_models
    [ GobiertoCalendars::Event ]
  end
end
