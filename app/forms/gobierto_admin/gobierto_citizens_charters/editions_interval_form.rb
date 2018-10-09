# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class EditionsIntervalForm < ::BaseForm
      attr_accessor :period
      attr_writer :period_interval

      validates :period_interval, :period, presence: true

      def period_interval
        return nil unless available_intervals.include? @period_interval

        @period_interval
      end

      def available_intervals
        ::GobiertoCitizensCharters::Edition.period_intervals.keys
      end

      def save
        return unless valid?

        edition = ::GobiertoCitizensCharters::Edition.new(period_interval: period_interval, period: period)
        @period_interval = edition.period_interval
        @period = edition.period_start
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
    end
  end
end
