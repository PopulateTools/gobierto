# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class CommitmentForm < GobiertoCitizensCharters::BaseForm
      attr_accessor(
        :charter_id,
        :title_translations,
        :description_translations,
        :slug
      )

      validates :charter, presence: true
      validates :title_translations, translated_attribute_presence: true

      def attributes_assignments
        {
          title_translations: title_translations,
          description_translations: description_translations,
          slug: slug
        }
      end

      private

      def resources_relation
        charter ? charter.commitments : ::GobiertoCitizensCharters::Commitment.none
      end

      def charter
        site.charters.find_by(id: charter_id)
      end
    end
  end
end
