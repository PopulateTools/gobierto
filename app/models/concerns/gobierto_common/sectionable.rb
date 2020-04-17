# frozen_string_literal: true

module GobiertoCommon
  module Sectionable
    extend ActiveSupport::Concern

    included do
      def section_id
        return if GobiertoCms::SectionItem.where(item: self).joins(:section).empty?

        GobiertoCms::SectionItem.where(item: self).first.section.id
      end

      def parent_id
        unless GobiertoCms::SectionItem.where(item: self).empty?
          if GobiertoCms::SectionItem.where(item: self).first.parent_id == 0
            0
          else
            GobiertoCms::SectionItem.where(item: self).first.parent.try(:id)
          end
        else
          nil
        end
      end

      def position
        unless GobiertoCms::SectionItem.where(item: self).empty?
          GobiertoCms::SectionItem.where(item: self).first.position
        else
          nil
        end
      end
    end
  end
end
