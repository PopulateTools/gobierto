module GobiertoCommon
  module Collectionable
    extend ActiveSupport::Concern

    included do
      belongs_to :collection, class_name: "GobiertoCommon::Collection"

      def collection_container
        collection&.container
      end
      alias_method :container, :collection_container

      def container_title
        collection_container&.title_as_container
      rescue
        nil
      end

      def container_path
        collection_container&.container_path
      end

      def process
        collection_item = GobiertoCommon::CollectionItem.on_processes.where(item: self).first
        collection_item.present? ? collection_item.container : nil
      end

      def person
        collection_item = GobiertoCommon::CollectionItem.on_people.where(item: self).first
        collection_item.present? ? collection_item.container : nil
      end
    end
  end
end
