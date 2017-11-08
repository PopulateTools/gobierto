# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class CommentFormTest < ActiveSupport::TestCase
    def valid_comment_form
      @valid_comment_form ||= CommentForm.new(
        site_id: site.id,
        user_id: comment.user_id,
        commentable_type: comment.commentable_type,
        commentable_id: comment.commentable_id,
        body: comment.body
      )
    end

    def invalid_comment_form
      @invalid_comment_form ||= CommentForm.new(
        site_id: nil,
        user_id: nil,
        commentable_type: nil,
        commentable_id: nil,
        body: nil
      )
    end

    def comment
      @comment ||= gobierto_participation_comments(:park_susan_comment)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_save_with_valid_attributes
      assert valid_comment_form.save
    end

    def test_error_messages_with_invalid_attributes
      invalid_comment_form.save

      assert_equal 1, invalid_comment_form.errors.messages[:site].size
    end
  end
end
