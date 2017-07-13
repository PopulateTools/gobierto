module GobiertoAdmin
  module GobiertoCommon
    class CollectionItemForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :collection_id,
        :item_type,
        :item_id,
        :container_type,
        :container_id
      )

      delegate :persisted?, to: :collection

      def save
        save_collection_item if valid?
      end

      def collection_item
        @collection_item ||= collection_item_class.find_by(id: id).presence || build_collection_item
      end

      def site_id
        @site_id ||= collection_item.site_id
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      private

      def build_collection_item
        collection_item_class.new
      end

      def collection_item_class
        ::GobiertoCommon::CollectionItem
      end

      def save_collection_item
        @collection_item = collection_item.tap do |collection_item_attributes|
          collection_item_attributes.collection_id = collection_id
          collection_item_attributes.item_type = item_type
          collection_item_attributes.container_type = container_type
          collection_item_attributes.container_id = container_id
        end

        if @collection_item.valid?
          @collection_item.save

          @collection_item
        else
          promote_errors(@collection_item.errors)

          false
        end
      end

      protected

      def promote_errors(errors_hash)
        errors_hash.each do |attribute, message|
          errors.add(attribute, message)
        end
      end
    end
  end
end
