# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  class DeleteIssueTest < ActionDispatch::IntegrationTest

    def setup
      super
      @path = admin_issues_path
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def site
      @site ||= sites(:madrid)
    end

    def issue
      @issue ||= gobierto_common_terms(:sports_term)
    end

    def issue_with_items
      @issue_with_items ||= gobierto_common_terms(:culture_term)
    end

    def test_delete_issue
      with_signed_in_admin(admin) do
        with_current_site(site) do
          visit @path

          within "#issue-item-#{issue.id}" do
            find("a[data-method='delete']").click
          end

          assert has_message?('Theme was successfully destroyed.')

          refute site.issues.exists?(id: issue.id)
        end
      end
    end

    def test_delete_issue_with_items
      with_signed_in_admin(admin) do
        with_current_site(site) do
          visit @path

          within "#issue-item-#{issue_with_items.id}" do
            find("a[data-method='delete']").click
          end

          assert has_message?("You can't delete a theme while it has associated elements.")

          assert site.issues.exists?(id: issue_with_items.id)
        end
      end
    end

  end
end
