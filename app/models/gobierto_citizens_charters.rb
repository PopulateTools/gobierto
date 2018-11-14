# frozen_string_literal: true

module GobiertoCitizensCharters
  def self.table_name_prefix
    "gcc_"
  end

  def self.classes_with_vocabularies
    [GobiertoCitizensCharters::Service]
  end

  def self.classes_with_custom_fields
    [GobiertoCitizensCharters::Service, GobiertoCitizensCharters::Charter]
  end

  def self.searchable_models
    [GobiertoCitizensCharters::Charter, GobiertoCitizensCharters::Commitment]
  end

  def self.module_submodules
    %w(services charters)
  end
end
