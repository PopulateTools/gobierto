# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCms
    class SectionItemSerializer < ActiveModel::Serializer
      attributes :id, :name

      has_many :children, serializer: GobiertoAdmin::GobiertoCms::SectionItemSerializer

      def name
        object.item.try(:title)
      end
    end
  end
end
