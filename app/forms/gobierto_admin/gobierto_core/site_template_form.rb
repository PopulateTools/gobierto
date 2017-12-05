# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCore
    class SiteTemplateForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :site_id,
        :markup,
        :template_id
      )

      delegate :persisted?, to: :site_template

      validates :site_id, presence: true

      def save
        save_site_template if valid?
      end

      def site_template
        @site_template ||= site_template_class.find_by(id: id).presence || build_site_template
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      private

      def build_site_template
        site_template_class.new
      end

      def site_template_class
        ::GobiertoCore::SiteTemplate
      end

      def save_site_template
        @site_template = site_template.tap do |site_template_attributes|
          site_template_attributes.site_id = site_id
          site_template_attributes.markup = markup
          site_template_attributes.template_id = template_id
        end

        if @site_template.valid?
          @site_template.save
        else
          promote_errors(@site_template.errors)

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
