# frozen_string_literal: true

module GobiertoPeople
  def self.table_name_prefix
    "gp_"
  end

  def self.classes_with_vocabularies
    [GobiertoPeople::Person]
  end

  def self.classes_with_custom_fields
    []
  end

  def self.searchable_models
    [ GobiertoPeople::Person, GobiertoPeople::PersonPost, GobiertoPeople::PersonStatement ]
  end

  def self.module_submodules
    %w(officials agendas blogs statements departments interest_groups trips gifts invitations)
  end

  def self.custom_engine_resources
    %w(events invitations gifts trips)
  end

  def self.remote_calendar_integrations
    %w( ibm_notes google_calendar microsoft_exchange )
  end

  def self.doc_url
    "https://gobierto.readme.io/docs/altos-cargos-y-agendas"
  end

  def self.root_path(_)
    Rails.application.routes.url_helpers.send("gobierto_people_root_#{I18n.locale}_path")
  end

  class << self
    alias_method :cache_base_key, :table_name_prefix
  end
end
