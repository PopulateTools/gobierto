# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class FlagFormTest < ActiveSupport::TestCase
    def valid_flag_form
      @valid_flag_form ||= FlagForm.new(
        site_id: site.id,
        user_id: flag.user_id,
        flaggable_type: flag.flaggable_type,
        flaggable_id: flag.flaggable_id
      )
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
  end
end
