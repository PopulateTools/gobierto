# frozen_string_literal: true

module GobiertoParticipation
  module PollResultsHelpers

    extend ActiveSupport::Concern

    included do

      ESTIMATION_MINIMUM_DAYS = 1

      def results_available?
        published? && closed? && past?
      end

      def unique_answers_count
        answers.select('DISTINCT user_id').count
      end

      def men_participation_percentage
        ((men_unique_answers_count * 100) / unique_answers_count).round
      end

      def women_participation_percentage
        100 - men_participation_percentage
      end

      def men_unique_answers_count
        answers.joins(:user).select('DISTINCT user_id').where('users.gender = 0').count
      end

      def women_unique_answers_count
        unique_answers_count - men_unique_answers_count
      end

      def predicted_unique_answers_count
        return unique_answers_count if !answerable?
        return nil if past_days < ESTIMATION_MINIMUM_DAYS

        (length_in_days * average_answers_per_day).round
      end

      def days_left
        (ends_at - Time.zone.now.to_date).to_i
      end

      def past_days
        (Time.zone.now.to_date - starts_at).to_i
      end

      def length_in_days
        (ends_at - starts_at).to_i
      end

      def average_answers_per_day
        (unique_answers_count / past_days.to_f)
      end

    end

  end
end
