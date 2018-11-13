# frozen_string_literal: true

module GobiertoCommon
  module Searchable
    extend ActiveSupport::Concern

    included do
      include AlgoliaSearch
      include ActionView::Helpers::SanitizeHelper

      def self.search_index_name
        "#{APP_CONFIG["site"]["name"]}_#{Rails.env}_#{name}"
      end

      def self.algoliasearch_gobierto(&block)
        algoliasearch(enqueue: :trigger_reindex_job, disable_indexing: Rails.env.test?, index_name: search_index_name, if: :active?, sanitize: true, &block)
      end

      def self.trigger_reindex_job(record, remove)
        return if record.nil? || (record.respond_to?(:site) && record.site.algolia_search_disabled?)

        GobiertoCommon::AlgoliaReindexJob.perform_later(record.class.name, record.id, remove)
      end
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
  end
end
