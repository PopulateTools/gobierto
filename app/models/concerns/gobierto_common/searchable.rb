# frozen_string_literal: true

module GobiertoCommon
  module Searchable
    extend ActiveSupport::Concern

    included do
      include ActionView::Helpers::SanitizeHelper
      include PgSearch::Model
    end

    def class_name
      self.class.name
    end

    def searchable_attribute(value)
      return "" unless value.present?

      strip_tags(value.tr("\n\r", " ").gsub(/\s+/, " "))[0..9300]
    end

    def searchable_translated_attribute(translations_hash)
      return "" if translations_hash.nil?

      attribute_summary = translations_hash.values.join(" ").tr("\n\r", " ").gsub(/\s+/, " ")
      attribute_summary = strip_tags(attribute_summary)
      attribute_summary[0..9300]
    end

    # pg_search

    def truncated_translations(attribute, opts = {})
      return localized_truncated_plain_attribute(attribute, opts) unless (translations_hash = try("#{attribute}_translations")).present?

      translations_hash.transform_values { |value| clean_text(value, limit: opts[:limit] || 1000, strip_tags: opts[:strip_tags] || true) }
    end

    def localized_truncated_plain_attribute(attribute, opts = {})
      return {} unless respond_to?(attribute)

      { I18n.locale => clean_text(send(attribute), limit: opts[:limit] || 1000, strip_tags: opts[:strip_tags] || true) }
    end

    def clean_text(text, limit: 1000, strip_tags: true)
      (strip_tags ? strip_tags(text) : text)&.truncate(limit)
    end

    def searchable?
      !try(:archived?) && try(:active?)
    end
  end
end
