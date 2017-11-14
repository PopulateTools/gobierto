# frozen_string_literal: true

module GobiertoCommon
  module Searchable
    extend ActiveSupport::Concern

    included do
      include AlgoliaSearch

      def self.search_index_name
        "#{APP_CONFIG["site"]["name"]}_#{Rails.env}_#{name}"
      end

      def self.algoliasearch_gobierto(&block)
        algoliasearch(enqueue: :trigger_reindex_job, disable_indexing: Rails.env.test?, index_name: search_index_name, if: :active?, sanitize: true, &block)
      end

      def self.trigger_reindex_job(record, remove)
        GobiertoCommon::AlgoliaReindexJob.perform_later(record.class.name, record.id, remove)
      end
    end

    def class_name
      self.class.name
    end
  end
end
