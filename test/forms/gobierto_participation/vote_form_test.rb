# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class VoteFormTest < ActiveSupport::TestCase

    def form_attributes
      @form_attributes ||= {
        site_id: site.id,
        user_id: vote.user_id,
        votable_type: vote.votable_type,
        votable_id: vote.votable_id,
        vote_weight: vote.vote_weight
      }
    end

    def valid_vote_form
      @valid_vote_form ||= VoteForm.new(form_attributes)
    end

    def invalid_vote_form
      @invalid_vote_form ||= begin
        VoteForm.new(form_attributes.each_key { |k| form_attributes[k] = nil })
      end
    end

    def vote
      @vote ||= gobierto_participation_votes(:park_susan_vote)
    end

    def site
      @site ||= sites(:madrid)
    end

    def contribution_on_closed_container
      @contribution_on_closed_container ||= gobierto_participation_contributions(:contribution_on_closed_container)
    end

    def comment_on_closed_contribution_container
      @comment_on_closed_contribution_container ||= begin
        gobierto_participation_comments(:susan_comment_on_closed_contribution_container)
      end
    end

    def test_save_with_valid_attributes
      assert valid_vote_form.save
    end

    def test_error_messages_with_invalid_attributes
      invalid_vote_form.save

      assert_equal 1, invalid_vote_form.errors.messages[:site].size
    end

    def test_vote_contribution_on_closed_contribution_container
      votable = contribution_on_closed_container

      vote_form = VoteForm.new(form_attributes.merge(
        votable_id: votable.id,
        votable_type: votable.class.to_s
      ))

      refute vote_form.save

      assert vote_form.errors.messages[:contribution_container].present?
    end

    def test_vote_comment_on_closed_contribution_container
      votable = comment_on_closed_contribution_container

      vote_form = VoteForm.new(form_attributes.merge(
        votable_id: votable.id,
        votable_type: votable.class.to_s
      ))

      refute vote_form.save

      assert vote_form.errors.messages[:contribution_container].present?
    end
  end
end
