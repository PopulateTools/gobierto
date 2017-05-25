# frozen_string_literal: true

module GobiertoPeople
  def self.table_name_prefix
    'gp_'
  end

  def self.searchable_models
    [GobiertoPeople::Person, GobiertoPeople::PersonPost, GobiertoPeople::PersonEvent, GobiertoPeople::PersonStatement]
  end

  def self.module_submodules
    %w[officials agendas blogs statements]
  end

  def self.remote_calendar_integrations
    %w[ibm_notes google_calendar]
  end
end
