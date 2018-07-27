# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class UpdateIssueTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = admin_common_vocabulary_terms_path(issues_vocabulary)
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def site
      @site ||= sites(:madrid)
    end

    def issues_vocabulary
      gobierto_common_vocabularies(:issues_vocabulary)
    end

    def participation_issue
      @participation_issue ||= gobierto_common_terms(:culture_term)
    end

    def test_update_issue
      with_javascript do
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            click_link participation_issue.name

            within "form.edit_term" do
              fill_in "term_name_translations_en", with: "Theme Culture updated"
              fill_in "term_description_translations_en", with: "Description Culture updated"
              fill_in "term_slug", with: "theme-culture-updated"

              click_button "Update"
            end

            assert has_message?("Term updated successfully.")

            click_link participation_issue.name

            assert has_field?("term_name_translations_en", with: "Theme Culture updated")
            assert has_field?("term_description_translations_en", with: "Description Culture updated")
            assert has_field?("term_slug", with: "theme-culture-updated")
          end
        end
      end
    end
  end
end
