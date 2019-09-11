# frozen_string_literal: true

module GobiertoCommon
  class TermSerializer < ActiveModel::Serializer

    attributes(
      :id,
      :name_translations,
      :description_translations,
      :slug,
      :position,
      :level,
      :term_id
    )

  end
end
