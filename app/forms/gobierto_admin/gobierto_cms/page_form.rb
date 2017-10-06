module GobiertoAdmin
  module GobiertoCms
    class PageForm
      include ActiveModel::Model
      prepend ::GobiertoCommon::Trackable

      attr_accessor(
        :id,
        :admin_id,
        :site_id,
        :collection_id,
        :visibility_level,
        :title_translations,
        :body_translations,
        :slug,
        :attachment_ids
      )

      delegate :persisted?, to: :page

      validates :site, :visibility_level, :collection_id, presence: true

      trackable_on :page

      notify_changed :visibility_level

      def save
        save_page if valid?
      end

      def admin_id
        @admin_id ||= page.admin_id
      end

      def collection
        @collection ||= collection_class.find_by(id: collection_id)
      end

      def page
        @page ||= page_class.find_by(id: id).presence || build_page
      end

      def site_id
        @site_id ||= collection.try(:site_id)
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def visibility_level
        @visibility_level ||= "draft"
      end

      private

      def build_page
        page_class.new
      end

      def page_class
        ::GobiertoCms::Page
      end

      def collection_class
        ::GobiertoCommon::Collection
      end

      def save_page
        @page = page.tap do |page_attributes|
          page_attributes.collection = collection
          page_attributes.site_id = site_id
          page_attributes.admin_id = admin_id
          page_attributes.title_translations = title_translations
          page_attributes.body_translations = body_translations
          page_attributes.slug = slug
          page_attributes.visibility_level = visibility_level
          if page.new_record? && attachment_ids.present?
            if attachment_ids.is_a?(String)
              page_attributes.attachment_ids = attachment_ids.split(',')
            else
              page_attributes.attachment_ids = attachment_ids
            end
          end
        end

        if @page.valid?
          run_callbacks(:save) do
            @page.save
          end

          @page
        else
          promote_errors(@page.errors)

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
