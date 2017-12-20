# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class CreateContributionContainerTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = edit_admin_participation_process_path(process)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:commission_for_carnival_festivities)
      end

      def test_create_contribution_container_errors
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            all("a", text: "Manage")[1].click

            click_on "New"
            click_button "Create"

            assert has_content?(process.title)

            assert has_alert?("Title can't be blank")
            assert has_alert?("Description can't be blank")
          end
        end
      end

      def test_create_contribution_container
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            all("a", text: "Manage")[1].click

            click_on "New"

            within "form.new_contribution_container" do
              fill_in "contribution_container_title_translations_en", with: "My contribution_container title"
              fill_in "contribution_container_description_translations_en", with: "My contribution_container description"
              fill_in "contribution_container_starts", with: "2017-01-01"
              fill_in "contribution_container_ends", with: "2017-01-30"

              click_link "ES"
              fill_in "contribution_container_title_translations_es", with: "Mi contendedor de aportaciones"
              fill_in "contribution_container_description_translations_es", with: "Descripción de mi contenedor de aportaciones"

              click_button "Create"
            end

            assert has_message?("Container of contributions created correctly")

            contribution_container = site.contribution_containers.last
            activity = Activity.last
            assert_equal contribution_container, activity.subject
            assert_equal admin, activity.author
            assert_equal site.id, activity.site_id
            assert_equal "gobierto_participation.contribution_container_created", activity.action
          end
        end
      end
    end
  end
end
