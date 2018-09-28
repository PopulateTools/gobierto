# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class CommitmentSerializer < ActiveModel::Serializer
      attributes(
        :id,
        :title_translations,
        :title,
        :edition,
        :slug
      )

      def edition
        return nil unless instance_options[:reference_edition].present?

        instance_options[:reference_edition].editions_of_same_period.where(commitment_id: object.id).first&.id
      end
    end
  end
end
