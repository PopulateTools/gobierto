# frozen_string_literal: true

require "test_helper"

module GobiertoCms
  class ProcessTest < ActiveSupport::TestCase
    def published_poll
      @published_poll ||= gobierto_participation_polls(:ordinance_of_terraces_published)
    end
    alias open_poll published_poll

    def draft_poll
      @draft_poll ||= gobierto_participation_polls(:schedules_draft)
    end

    def future_poll
      @future_poll ||= gobierto_participation_polls(:public_spaces_future)
    end
    alias poll future_poll

    def past_poll
      @past_poll ||= gobierto_participation_polls(:noise_problems_past)
    end
    alias finished_poll_with_answers past_poll

    def test_valid
      assert published_poll.valid?
      assert draft_poll.valid?
      assert future_poll.valid?
      assert past_poll.valid?
    end

    def test_prohibit_editing_poll_with_answers
      assert_raises GobiertoParticipation::Poll::PollHasAnswers do
        published_poll.update_attributes(title: "wadus")
      end
    end

    def test_answerable?
      assert published_poll.answerable?
      refute draft_poll.answerable?
      refute future_poll.answerable?
      refute past_poll.answerable?
    end

    def test_editable?
      refute open_poll.editable?
      assert draft_poll.editable?
      assert future_poll.editable?
      refute past_poll.editable?
    end

    def test_unique_answers_count
      assert_equal 0, future_poll.unique_answers_count
      assert_equal 3, finished_poll_with_answers.unique_answers_count
    end

    def test_unique_answers_count_by_gender
      assert_equal 2, finished_poll_with_answers.men_unique_answers_count
      assert_equal 1, finished_poll_with_answers.women_unique_answers_count
    end

    def test_participation_percentage_by_gender
      assert_equal 67, finished_poll_with_answers.men_participation_percentage
      assert_equal 33, finished_poll_with_answers.women_participation_percentage
    end

    def test_predicted_unique_answers_count
      # total: 28 days, past: 15 days, answers: 23, avg/day: 1.533x
      # prediction: (28*1.533) ~> 42.933 ~> 43
      poll.update_attributes!(starts_at: 15.days.ago, ends_at: 13.days.from_now)
      poll.stubs(:unique_answers_count).returns(23)

      assert_equal 43, poll.predicted_unique_answers_count
    end

    def test_predicted_answers_returns_actual_answers_for_inactive_polls
      assert_equal 0, draft_poll.predicted_unique_answers_count
      assert_equal 0, future_poll.predicted_unique_answers_count

      past_poll.stubs(:unique_answers_count).returns(123)
      assert_equal 123, past_poll.predicted_unique_answers_count
    end

    def test_predicted_answers_under_estimation_limit
      poll.update_attributes!(
        starts_at: Time.zone.now, # started today
        ends_at: 10.days.from_now
      )

      assert_nil poll.predicted_unique_answers_count
    end

    def test_past_days
      poll.update_attributes!(starts_at: Time.zone.now)
      assert_equal 0, poll.past_days

      poll.update_attributes!(starts_at: 15.days.ago)
      assert_equal 15, poll.past_days
    end

    def test_length_in_days
      poll.update_attributes!(starts_at: 7.days.ago, ends_at: 3.days.from_now)

      assert_equal 10, poll.length_in_days
    end

    def test_average_answers_per_day
      poll.update_attributes!(starts_at: 10.days.ago)
      poll.stubs(:unique_answers_count).returns(23)

      assert_equal 2.3, poll.average_answers_per_day
    end
  end
end
