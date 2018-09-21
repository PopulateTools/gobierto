# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class CommitmentSerializer < ActiveModel::Serializer
      attributes(
        :id,
        :title_translations,
        :slug
      )
    end
  end
end
