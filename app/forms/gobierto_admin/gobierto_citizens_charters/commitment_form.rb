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

      trackable_on :resource
      notify_changed :visibility_level
      notify_changed :title_translations, :description_translations, as: :commitment_attribute
      use_publisher Publishers::AdminGobiertoCitizensChartersActivity
      use_trackable_subject :charter

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
