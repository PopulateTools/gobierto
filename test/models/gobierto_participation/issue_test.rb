require "test_helper"

module GobiertoParticipation
  class IssueTest < ActiveSupport::TestCase
    def issue
      @issue ||= gobierto_participation_issues(:culture)
    end

    def test_valid
      assert issue.valid?
    end

    def test_find_by_slug
      assert_nil GobiertoParticipation::Issue.find_by_slug! nil
      assert_nil GobiertoParticipation::Issue.find_by_slug! ""
      assert_raises(ActiveRecord::RecordNotFound) do
        GobiertoParticipation::Issue.find_by_slug! "foo"
      end

      assert_equal issue, GobiertoParticipation::Issue.find_by_slug!(issue.slug_es)
      assert_equal issue, GobiertoParticipation::Issue.find_by_slug!(issue.slug_en)
    end
  end
end
