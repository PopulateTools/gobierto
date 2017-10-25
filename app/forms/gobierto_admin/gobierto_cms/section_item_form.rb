# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCms
    class SectionItemForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :item_type,
        :item_id,
        :section_id,
        :parent_id,
        :position,
        :level
      )

      delegate :persisted?, to: :section_item

      def save
        save_section_item if valid?
      end

      def section_item
        @section_item ||= section_item_class.find_by(id: id).presence || build_section_item
      end

      private

      def build_section_item
        section_item_class.new
      end

      def section_item_class
        ::GobiertoCms::SectionItem
      end

      def save_section_item
        @section_item = section_item.tap do |section_item_attributes|
          section_item_attributes.item_type = item_type
          section_item_attributes.item_id = item_id
          section_item_attributes.section_id = section_id
          section_item_attributes.parent_id = parent_id
          section_item_attributes.position = position
          section_item_attributes.level = level
        end

        if @section_item.valid?
          @section_item.save
        else
          promote_errors(@section_item.errors)

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
