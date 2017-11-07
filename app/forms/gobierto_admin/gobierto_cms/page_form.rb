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
        :attachment_ids,
        :has_section,
        :section,
        :parent
      )

      delegate :persisted?, to: :page

      validates :site, :visibility_level, :collection_id, presence: true

      trackable_on :page

      notify_changed :visibility_level

      def initialize(options = {})
        options = options.to_h.with_indifferent_access

        # reorder attributes so site and process get assigned first
        ordered_options = {
          site_id: options[:site_id],
          id: options[:id]
        }.with_indifferent_access
        ordered_options.merge!(options)

        # overwritte options[:has_duration]
        ordered_options.merge!(has_section: page.section.present?)

        super(ordered_options)
      end

      def save
        save_page if valid?
      end

      def admin_id
        @admin_id ||= page.admin_id
      end

      # def section
      #   @section ||= page.section
      # end
      #
      # def parent
      #   @parent ||= page.parent
      # end

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

      def save_section_item(id, section, parent)
        parent = parent ? parent : 0
        parent_node = ::GobiertoCms::SectionItem.find_by(id: parent, section: section)
        position = ::GobiertoCms::SectionItem.where(parent_id: parent, section: section).size
        section_item = ::GobiertoCms::SectionItem.find_or_initialize_by(item_id: id,
                                                                        parent_id: parent,
                                                                        item_type: "GobiertoCms::Page",
                                                                        section_id: section,
                                                                        position: position,
                                                                        level: parent_node ? parent_node.level + 1 : 0)
        section_item.save
        byebug
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
          save_section_item(@page.id, section, parent)

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
