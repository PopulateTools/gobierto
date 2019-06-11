# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class VocabularySerializer < ActiveModel::Serializer

      attributes(
        :id,
        :name_translations,
        :slug
      )

      has_many :terms, serializer: TermSerializer

    end
  end
end
