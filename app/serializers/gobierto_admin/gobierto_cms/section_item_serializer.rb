# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCms
    class SectionItemSerializer < ActiveModel::Serializer
      attributes :id, :name

      has_many :child_section_items

      def name
        object.item.try(:title)
      end
    end
  end
end
