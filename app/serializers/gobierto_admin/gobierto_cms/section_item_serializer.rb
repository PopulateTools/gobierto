# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCms
    class SectionItemSerializer < ActiveModel::Serializer
      attributes :id, :name, :children

      def children
        object.childrens.sorted.map do |children|
          GobiertoAdmin::GobiertoCms::SectionItemSerializer.new(children)
        end
      end

      def name
        object.item.try(:title)
      end
    end
  end
end
