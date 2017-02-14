module GobiertoCommon
  module Searchable
    extend ActiveSupport::Concern

    included do
      include AlgoliaSearch

      def self.search_index_name
        "#{APP_CONFIG["site"]["name"]}_#{Rails.env}_#{self.name}"
      end

      def self.algoliasearch_gobierto(&block)
        algoliasearch(enqueue: true, disable_indexing: Rails.env.test?, index_name: search_index_name, if: :active?, sanitize: true, &block)
      end
    end

    def class_name
      self.class.name
    end
  end
end
