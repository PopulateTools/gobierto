# frozen_string_literal: true

module GobiertoCommon
  module Sectionable
    extend ActiveSupport::Concern

    included do

      def section_id
        unless GobiertoCms::SectionItem.where(item: self).empty?
          GobiertoCms::SectionItem.where(item: self).first.section.id
        else
          nil
        end
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
    end
  end
end
