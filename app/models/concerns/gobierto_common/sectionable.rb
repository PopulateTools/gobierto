# frozen_string_literal: true

module GobiertoCommon
  module Sectionable
    extend ActiveSupport::Concern

    included do
      has_many :section_items, as: :item, class_name: "GobiertoCms::SectionItem"
      has_many :sections, through: :section_items

      def section
        sections.first
      end

      def section_id
        section&.id
      end

      def parent_id
        return unless section_items.exists?

        section_item = section_items.first

        section_item.parent_id.zero? ? 0 : section_item.parent&.id
      end

      def position
        section_items.first&.position
      end
    end
  end
end
