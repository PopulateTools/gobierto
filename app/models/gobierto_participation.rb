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

  def self.doc_url
    "https://gobierto.readme.io/docs/participaci%C3%B3n"
  end
end
