module GobiertoCommon
  module Collectionable
    extend ActiveSupport::Concern

    included do

      def collection_container
        collection.container
      end

      def container_title
        collection_container.title_as_container
      rescue
        nil
      end

      def container_path
        collection_container.container_path
      end

    end

  end
end
