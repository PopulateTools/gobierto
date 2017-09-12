require 'test_helper'

module GobiertoCms
  class ProcessTest < ActiveSupport::TestCase

    def published_poll
      @published_poll ||= gobierto_participation_polls(:ordinance_of_terraces_published)
    end

    def draft_poll
      @draft_poll ||= gobierto_participation_polls(:schedules_draft)
    end

    def future_poll
      @future_poll ||= gobierto_participation_polls(:public_spaces_future)
    end

    def past_poll
      @past_poll ||= gobierto_participation_polls(:noise_problems_past)
    end

    def test_valid
      assert published_poll.valid?
      assert draft_poll.valid?
      assert future_poll.valid?
      assert past_poll.valid?
    end

    def test_prohibit_editing_poll_with_answers
      assert_raises GobiertoParticipation::Poll::PollHasAnswers do
        published_poll.update_attributes(title: 'wadus')
      end
    end

    def test_answerable?
      assert published_poll.answerable?
      refute draft_poll.answerable?
      refute future_poll.answerable?
      refute past_poll.answerable?
    end

  end
end
