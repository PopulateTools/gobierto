# frozen_string_literal: true

module GobiertoCommon
  module Collectionable
    extend ActiveSupport::Concern

    included do
      belongs_to :collection, class_name: "GobiertoCommon::Collection"

      scope :in_collections, lambda { |site|
        joins(Arel.sql("join collection_items on collection_items.item_id = #{ table_name }.id"))
          .where("collection_items.item_type = ?", name)
          .where(site: site)
          .distinct
      }

      scope :in_collections_and_container_type, lambda { |site, container_type|
        in_collections(site)
          .where("collection_items.container_type = ?", container_type)
      }

      scope :in_collections_and_container, lambda { |site, container|
        in_collections(site)
          .where("collection_items.container_type = ?", container.class.name)
          .where("collection_items.container_id = ?", container.id)
      }

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
