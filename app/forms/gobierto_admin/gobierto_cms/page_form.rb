# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCms
    class PageForm < BaseForm

      attr_accessor(
        :id,
        :admin_id,
        :site_id,
        :collection_id,
        :visibility_level,
        :title_translations,
        :body_translations,
        :body_source_translations,
        :slug,
        :attachment_ids,
        :section,
        :published_on,
        :template,
        :parent
      )

      delegate :persisted?, to: :page

      validates :site, :visibility_level, :collection_id, presence: true
      validate :confirm_presence_of_homepage

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

      def published_on
        @published_on ||= Time.zone.now
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

      def save_section_item(id, section, parent)
        parent ||= 0
        parent_node = ::GobiertoCms::SectionItem.find_by(id: parent, section: section)
        position = if @page.parent_id == parent.to_i
                     @page.position
                   else
                     ::GobiertoCms::SectionItem.where(parent_id: parent, section: section).size
                   end

        section_item = ::GobiertoCms::SectionItem.find_or_initialize_by(item_id: id,
                                                                        item_type: "GobiertoCms::Page")
        if section == "" && section_item.present?
          section_item.destroy
        else
          section_item.update_attributes(parent_id: parent,
                                         section_id: section,
                                         position: position,
                                         level: parent_node ? parent_node.level + 1 : 0)
        end
      end

      def save_page
        @page = page.tap do |page_attributes|
          page_attributes.collection = collection
          page_attributes.site_id = site_id
          page_attributes.admin_id = admin_id
          page_attributes.title_translations = title_translations
          page_attributes.body_translations = body_translations
          page_attributes.body_source_translations = body_source_translations
          page_attributes.slug = slug
          page_attributes.visibility_level = visibility_level
          page_attributes.published_on = published_on
          if page.new_record? && attachment_ids.present?
            if attachment_ids.is_a?(String)
              page_attributes.attachment_ids = attachment_ids.split(",")
            else
              page_attributes.attachment_ids = attachment_ids
            end
          end
        end

        if @page.valid?
          @page.save

          save_section_item(@page.id, section, parent)

          @page
        else
          promote_errors(@page.errors)

          false
        end
      end

      def confirm_presence_of_homepage
        if site.try(:configuration)
          if page == GlobalID::Locator.locate(site.configuration.try(:home_page_item_id)) && visibility_level == "draft"
            errors[:base] << I18n.t("errors.messages.page_as_homepage")
          end
        end
      end

    end
  end
end
