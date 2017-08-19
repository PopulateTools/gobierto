module GobiertoCommon
  module ActsAsCollectionContainer
    extend ActiveSupport::Concern

    class_methods do

      def container_type_name
        to_s.underscore
      end

      def url_helpers
        Rails.application.routes.url_helpers
      end

    end

    included do

      after_destroy :clean_collection_items

      def title_as_container
        title = try(:title) || try(:name)
      end

      def container_type
        self.class.container_type_name
      end

      def news_in_collections
        ids = GobiertoCommon::CollectionItem.where(collection: news_collection).map(&:item_id)
        GobiertoCms::Page.where(id: ids, site: site)
      end

      def events_in_collections
        collection_items_table = CollectionItem.table_name
        item_type = GobiertoCalendars::Event

        site.events.joins("INNER JOIN #{collection_items_table} ON           \
          #{collection_items_table}.item_id = #{item_type.table_name}.id AND \
          #{collection_items_table}.item_type = '#{item_type}' AND           \
          container_type = '#{self.class}' AND                               \
          container_id = #{self.id}                                          \
        ")
      end

      def attachments_in_collections
        ids = GobiertoCommon::CollectionItem.where(collection: attachments_collection).map(&:item_id)
        GobiertoAttachments::Attachment.where(id: ids, site: site)
      end

      def container_path
        case
        when self.class == GobiertoParticipation::Process
          self.class.url_helpers.gobierto_participation_process_path(self.slug)
        end
      end

      def news_collection
        @news_collection ||= GobiertoCommon::Collection.find_by(container: self, item_type: 'GobiertoCms::Page')
      end

      def events_collection
        @events_collection ||= GobiertoCommon::Collection.find_by(container: self, item_type: 'GobiertoCalendars::Event')
      end

      def attachments_collection
        @attachments_collection ||= GobiertoCommon::Collection.find_by(container: self, item_type: 'GobiertoAttachments::Attachment')
      end

    end

    def self.container_klass_for
      {
        GobiertoParticipation::Process.container_type_name => GobiertoParticipation::Process
      }
    end

    private

    def clean_collection_items
      GobiertoCommon::CleanCollectionItemsJob.perform_later(self.site_id, self.class.name, self.id)
    end

  end
end
