# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class IssueFormTest < ActiveSupport::TestCase
    def valid_issue_form
      @valid_issue_form ||= IssueForm.new(
        site_id: site.id,
        name_translations: { I18n.locale => issue.name },
        description_translations: { I18n.locale => issue.description },
        slug: nil
      )
    end

    def invalid_issue_form
      @invalid_issue_form ||= IssueForm.new(
        site_id: nil,
        name_translations: nil,
        description_translations: nil,
        slug: nil
      )
    end

    def issue
      @issue ||= issues(:culture)
    end

    def site
      @site ||= sites(:santander)
    end

    def test_save_with_valid_attributes
      assert valid_issue_form.save
    end

    def test_error_messages_with_invalid_attributes
      invalid_issue_form.save

      assert_equal 1, invalid_issue_form.errors.messages[:site].size
    end
  end
end
