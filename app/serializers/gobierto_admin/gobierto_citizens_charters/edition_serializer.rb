# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class EditionSerializer < ActiveModel::Serializer
      attributes(
        :id,
        :title_translations,
        :commitment_id,
        :proportion,
        :percentage,
        :value,
        :max_value,
        :period_interval,
        :period
      )

      def title_translations
        object.commitment.title_translations
      end
    end
  end
end
