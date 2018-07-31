# frozen_string_literal: true

module GobiertoParticipation
  def self.table_name_prefix
    "gpart_"
  end

  def self.classes_with_vocabularies
    [GobiertoParticipation::Process]
  end

  def self.searchable_models
    [GobiertoParticipation::Process, GobiertoParticipation::Contribution]
  end
end
