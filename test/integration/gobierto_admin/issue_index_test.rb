# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class IssueIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = admin_ordered_vocabulary_terms_path(module: "gobierto_participation", vocabulary: "issues")
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def site
      @site ||= sites(:madrid)
    end

    def issues
      @issues ||= site.issues
    end

    def test_issues_index
      with_signed_in_admin(admin) do
        with_current_site(site) do
          visit @path

          within "table tbody" do
            assert has_selector?("tr", count: issues.size)

            issues.each do |issue|
              assert has_selector?("tr#term-item-#{issue.id}")

              within "tr#term-item-#{issue.id}" do
                assert has_link?(issue.name.to_s)
              end
            end
          end
        end
      end
    end
  end
end
