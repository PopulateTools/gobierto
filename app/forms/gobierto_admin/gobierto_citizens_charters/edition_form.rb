# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class EditionForm < GobiertoCitizensCharters::BaseForm
      attr_accessor(
        :charter_id,
        :commitment_id,
        :percentage,
        :value,
        :max_value,
        :period,
        :period_interval
      )

      validates :commitment, :period, :period_interval, :charter, presence: true
      validates :percentage, presence: true, if: ->(object) { object.value.blank? || object.max_value.blank? }
      validates :value, :max_value, presence: true, if: ->(object) { object.percentage.blank? }
      validate :period_uniqueness

      trackable_on :resource
      notify_changed :commitment_id, :percentage, :value, :max_value, as: :edition_attribute
      use_publisher Publishers::AdminGobiertoCitizensChartersActivity
      use_trackable_subject :charter

      def attributes_assignments
        {
          commitment_id: commitment_id,
          percentage: percentage,
          value: value,
          max_value: max_value,
          period: period,
          period_interval: period_interval
        }
      end

      private

      def resources_relation
        charter ? charter.editions : ::GobiertoCitizensCharters::Edition.none
      end

      def commitment
        charter.commitments.find_by(id: commitment_id)
      end

      def charter
        site.charters.find_by(id: charter_id)
      end

      def period_uniqueness
        reference_edition = ::GobiertoCitizensCharters::Edition.new(period_interval: period_interval, period: period)
        if commitment.editions.of_same_period(reference_edition).where.not(id: id).any?
          errors.add(:period, I18n.t("errors.messages.taken"))
        end
      end
    end
  end
end
