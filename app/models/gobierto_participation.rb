module GobiertoParticipation
  def self.table_name_prefix
    'gpart_'
  end

  def self.searchable_models
    [ GobiertoParticipation::Process ]
  end
end
