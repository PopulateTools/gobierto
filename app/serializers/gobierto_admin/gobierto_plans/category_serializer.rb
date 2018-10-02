# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class CategorySerializer < ActiveModel::Serializer
      attributes(
        :id,
        :name_translations,
        :description_translations,
        :slug,
        :position,
        :children,
        :level,
        :term_id
      )

      def children
        categories_model.where(term_id: object.id).pluck(:id)
      end

      def categories_model
        ::GobiertoCommon::Term
      end
    end
  end
end
