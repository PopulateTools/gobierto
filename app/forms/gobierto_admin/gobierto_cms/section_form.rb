# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCms
    class SectionForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :site_id,
        :title_translations,
        :slug
      )

      delegate :persisted?, to: :section

      validates :site, presence: true

      def save
        save_section if valid?
      end

      def section
        @section ||= section_class.find_by(id: id).presence || build_section
      end

      def site_id
        @site_id ||= section.site_id
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      private

      def build_section
        section_class.new
      end

      def section_class
        ::GobiertoCms::Section
      end

      def save_section
        @section = section.tap do |section_attributes|
          section_attributes.site_id = site_id
          section_attributes.title_translations = title_translations
          section_attributes.slug = slug
        end

        if @section.valid?
          @section.save
        else
          promote_errors(@section.errors)

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
