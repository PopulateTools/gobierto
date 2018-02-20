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

      def process
        collection_item = GobiertoCommon::CollectionItem.by_container_type("GobiertoParticipation::Process").where(item_id: id).first
        collection_item.present? ? collection_item.container : nil
      end
    end
  end
end
