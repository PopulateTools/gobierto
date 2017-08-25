# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class CommentTest < ActiveSupport::TestCase
    def comment
      @comment ||= gobierto_participation_comments(:cinema_comment)
    end

    def test_valid
      assert comment.valid?
    end
  end
end
