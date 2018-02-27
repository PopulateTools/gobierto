# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class FlagFormTest < ActiveSupport::TestCase

    def flag_form_attributes
      @flag_form_attributes ||= {
        site_id: site.id,
        user_id: flag.user_id,
        flaggable_type: flag.flaggable_type,
        flaggable_id: flag.flaggable_id
      }
    end

    def valid_flag_form
      @valid_flag_form ||= FlagForm.new(flag_form_attributes)
    end

    def invalid_flag_form
      @invalid_flag_form ||= FlagForm.new(
        site_id: nil,
        user_id: nil,
        flaggable_type: nil,
        flaggable_id: nil
      )
    end

    def flag
      @flag ||= gobierto_participation_flags(:contribution_flag)
    end

    def comment_on_closed_contribution_container
      @comment_on_closed_contribution_container ||= begin
        gobierto_participation_comments(:susan_comment_on_closed_contribution_container)
      end
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_save_with_valid_attributes
      assert valid_flag_form.save
    end

    def test_error_messages_with_invalid_attributes
      invalid_flag_form.save

      assert_equal 1, invalid_flag_form.errors.messages[:site].size
    end

    def test_flag_comment_on_closed_contribution_container
      comment = comment_on_closed_contribution_container

      flag_form = FlagForm.new(flag_form_attributes.merge(
        flaggable_id: comment.id,
        flaggable_type: comment.class.to_s
      ))

      refute flag_form.save

      assert flag_form.errors.messages[:contribution_container].present?
    end
  end
end
