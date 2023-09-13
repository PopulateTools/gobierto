# frozen_string_literal: true

module GobiertoCommon
  class ApiTermSerializer < ActiveModel::Serializer
    attributes(
      :id,
      :name_translations,
      :description_translations,
      :slug,
      :position,
      :level,
      :term_id,
      :parent_external_id,
      :external_id
    )
  end
end
