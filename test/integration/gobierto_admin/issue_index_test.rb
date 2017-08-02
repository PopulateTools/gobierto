require "test_helper"

module GobiertoAdmin
  class IssueIndexTest < ActionDispatch::IntegrationTest
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
              assert has_selector?("tr#issue-item-#{issue.id}")

              within "tr#issue-item-#{issue.id}" do
                assert has_link?("#{issue.name}")
              end
            end
          end
        end
      end
    end
  end
end
