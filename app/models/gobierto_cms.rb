# frozen_string_literal: true

module GobiertoCms
  def self.table_name_prefix
    "gcms_"
  end

  def self.searchable_models
    [GobiertoCms::Page]
  end

  def self.classes_with_custom_fields
    [GobiertoCms::Page]
  end

  def self.classes_with_custom_fields_at_instance_level
    [GobiertoCms::PagesCollection]
  end

  def self.custom_fields_at_instance_level_only?
    true
  end

  def self.doc_url
    "https://gobierto.readme.io/docs/cms"
  end

  def self.root_path(_)
    Rails.application.routes.url_helpers.root_path
  end
end
