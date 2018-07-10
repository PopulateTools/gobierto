# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class ContentBlockForm < BaseForm

      attr_accessor(
        :id,
        :site_id,
        :content_model_name,
        :referrer_url,
        :available_locales,
        :title,
        :title_components,
        :title_components_attributes,
        :fields,
        :fields_attributes
      )

      delegate :persisted?, to: :content_block

      validates :title, presence: true
      validates :site, presence: true

      def save
        save_content_block if valid?
      end

      def content_block
        @content_block ||= content_block_class.find_by(id: id).presence || build_content_block
      end

      def site_id
        @site_id ||= content_block.site_id
      end

      def title
        @title ||= content_block.title
      end

      def site
        @site ||= Site.find(site_id)
      end

      def fields
        @fields ||= retrieve_content_block_fields.presence || [build_content_block_field]
      end

      def fields_attributes=(attributes)
        @fields ||= Array(attributes).map do |_, field_attributes|
          next if field_attributes["_destroy"] == "1"

          if field_attributes["id"].present?
            content_block_field = content_block_field_class.find_by(id: field_attributes["id"])

            next unless content_block_field.present?

            content_block_field.assign_attributes(field_attributes.except("_destroy"))
            content_block_field if content_block_field.save
          else
            content_block_field_class.new(field_attributes.except("_destroy"))
          end
        end
      end

      def content_model_name
        @content_model_name ||= content_block.content_model_name
      end

      def title_components_attributes=(attributes)
        @title ||= Array(attributes).reduce({}) do |title, (_, title_component)|
          title.merge!({ title_component["locale"] => title_component["value"] })
        end
      end

      def title_components
        available_locales.map do |locale|
          OpenStruct.new(
            locale: locale.to_s,
            value: (title[locale.to_s] if title)
          )
        end
      end

      private

      def build_content_block
        content_block_class.new
      end

      def build_content_block_field
        content_block.fields.build(available_locales: available_locales)
      end

      def retrieve_content_block_fields
        Array(content_block.fields).map do |content_block_field|
          content_block_field.tap do |content_block_field_attributes|
            content_block_field_attributes.available_locales = available_locales
          end
        end
      end

      def content_block_class
        ::GobiertoCommon::ContentBlock
      end

      def content_block_field_class
        ::GobiertoCommon::ContentBlockField
      end

      def save_content_block
        @content_block = content_block.tap do |content_block_attributes|
          content_block_attributes.site_id = site_id
          content_block_attributes.content_model_name = content_model_name
          content_block_attributes.title = title
          content_block_attributes.fields = fields.compact
        end

        if @content_block.valid?
          @content_block.save

          @content_block
        else
          promote_errors(@content_block.errors)

          false
        end
      end

    end
  end
end
