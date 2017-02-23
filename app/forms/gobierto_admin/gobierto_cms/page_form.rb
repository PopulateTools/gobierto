module GobiertoAdmin
  module GobiertoCms
    class PageForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :site_id,
        :title,
        :body,
        :slug,
        :visibility_level,
      )

      delegate :persisted?, to: :page

      validates :site, :title, :body, :slug, :visibility_level, presence: true

      def save
        save_page if valid?
      end

      def page
        @page ||= page_class.find_by(id: id).presence || build_page
      end

      def site_id
        @site_id ||= page.site_id
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

      def save_page
        @page = page.tap do |page_attributes|
          page_attributes.site_id = site_id
          page_attributes.title = title
          page_attributes.body = body
          page_attributes.slug = slug
          page_attributes.visibility_level = visibility_level
        end

        if @page.valid?
          @page.save

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
