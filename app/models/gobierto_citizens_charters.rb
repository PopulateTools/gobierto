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

  def self.doc_url
    "https://gobierto.readme.io/docs/servicios-y-cartas-de-servicio"
  end

  def self.root_path(current_site)
    if current_site.gobierto_citizens_charters_settings&.enable_services_home
      Rails.application.routes.url_helpers.gobierto_citizens_charters_services_path
    else
      reference_edition = ::GobiertoCitizensCharters::CharterDecorator.new(current_site).reference_edition
      Rails.application.routes.url_helpers.gobierto_citizens_charters_charters_period_path(reference_edition.front_period_params)
    end
  end
end
