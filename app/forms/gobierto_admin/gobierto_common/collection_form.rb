module GobiertoAdmin
  module GobiertoCommon
    class CollectionForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :site_id,
        :title_translations,
        :slug,
        :global_entity,
        :container_id,
        :item_type
      )

      delegate :persisted?, to: :collection

      validates :site, presence: true

      def save
        save_collection if valid?
      end

      def collection
        @collection ||= collection_class.find_by(id: id).presence || build_collection
      end

      def site_id
        @site_id ||= collection.site_id
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      private

      def build_collection
        collection_class.new
      end

      def collection_class
        ::GobiertoCommon::Collection
      end

      def save_collection
        @collection = collection.tap do |collection_attributes|
          collection_attributes.site_id = site_id
          collection_attributes.title_translations = title_translations
          collection_attributes.slug = slug
          # TODO: Generalize
          collection_attributes.container = ::GobiertoParticipation::Issue.find(container_id)
          collection_attributes.item_type = item_type
        end

        if @collection.valid?
          @collection.save

          @collection
        else
          promote_errors(@collection.errors)

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
