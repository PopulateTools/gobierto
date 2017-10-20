# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class VoteFormTest < ActiveSupport::TestCase
    def valid_vote_form
      @valid_vote_form ||= VoteForm.new(
        site_id: site.id,
        user_id: vote.user_id,
        votable_type: vote.votable_type,
        votable_id: vote.votable_id,
        vote_weight: vote.vote_weight
      )
    end

    def invalid_vote_form
      @invalid_vote_form ||= VoteForm.new(
        site_id: nil,
        user_id: nil,
        votable_type: nil,
        votable_id: nil,
        vote_weight: nil
      )
    end

    def vote
      @vote ||= gobierto_participation_votes(:park_susan_vote)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_save_with_valid_attributes
      assert valid_vote_form.save
    end

    def test_error_messages_with_invalid_attributes
      invalid_vote_form.save

      assert_equal 1, invalid_vote_form.errors.messages[:site].size
    end
  end
end
