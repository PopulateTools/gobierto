# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Commitments
      class UpdateServiceTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = edit_admin_citizens_charters_charter_commitment_path(charter, commitment)
          @draft_commitment_path = edit_admin_citizens_charters_charter_commitment_path(charter, draft_commitment)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def unauthorized_admin
          @unauthorized_admin ||= gobierto_admin_admins(:steve)
        end

        def site
          @site ||= sites(:madrid)
        end

        def charter
          @charter ||= gobierto_citizens_charters_charters(:day_care_service_charter)
        end

        def commitment
          @commitment ||= gobierto_citizens_charters_commitments(:average_response_time)
        end

        def draft_commitment
          @draft_commitment ||= gobierto_citizens_charters_commitments(:draft_service_schedule)
        end

        def test_permissions
          with_signed_in_admin(unauthorized_admin) do
            with_current_site(site) do
              visit @path
              assert has_content?("You are not authorized to perform this action")
              assert_equal admin_root_path, current_path
            end
          end
        end

        def test_update_commitment
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                fill_in "commitment_title_translations_en", with: "Commitment updated"
                fill_in "commitment_description_translations_en", with: "Commitment updated description"
                click_link "ES"
                fill_in "commitment_title_translations_es", with: "Compromiso actualizado"
                fill_in "commitment_description_translations_es", with: "Descripción del compromiso actualizado"

                click_button "Update"

                assert has_message?("The commitment has been correctly updated.")

                visit @path

                assert has_field? "commitment_title_translations_en", with: "Commitment updated"
                assert has_field? "commitment_description_translations_en", with: "Commitment updated description"
                click_link "ES"
                assert has_field? "commitment_title_translations_es", with: "Compromiso actualizado"
                assert has_field? "commitment_description_translations_es", with: "Descripción del compromiso actualizado"
              end
            end
          end

          activity = Activity.last
          assert_equal charter, activity.subject
          assert_equal admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_citizens_charters.charter.commitment_updated", activity.action
        end

        def test_update_draft_commitment
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                assert_no_difference "Activity.count" do
                  visit @draft_commitment_path

                  fill_in "commitment_title_translations_en", with: "Commitment updated"
                  fill_in "commitment_description_translations_en", with: "Commitment updated description"
                  click_link "ES"
                  fill_in "commitment_title_translations_es", with: "Compromiso actualizado"
                  fill_in "commitment_description_translations_es", with: "Descripción del compromiso actualizado"

                  click_button "Update"

                  assert has_message?("The commitment has been correctly updated.")

                  visit @draft_commitment_path

                  assert has_field? "commitment_title_translations_en", with: "Commitment updated"
                  assert has_field? "commitment_description_translations_en", with: "Commitment updated description"
                  click_link "ES"
                  assert has_field? "commitment_title_translations_es", with: "Compromiso actualizado"
                  assert has_field? "commitment_description_translations_es", with: "Descripción del compromiso actualizado"
                end
              end
            end
          end
        end

        def test_publish_draft_commitment
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @draft_commitment_path

                within ".widget_save" do
                  find("label", text: "Published").click
                end

                click_button "Update"

                assert has_message?("The commitment has been correctly updated.")

                visit @draft_commitment_path

                assert has_field? "commitment_title_translations_en", with: draft_commitment.title_en
                assert has_field? "commitment_description_translations_en", with: draft_commitment.description_en
                click_link "ES"
                assert has_field? "commitment_title_translations_es", with: draft_commitment.title_es
                assert has_field? "commitment_description_translations_es", with: draft_commitment.description_es
              end
            end
          end

          activity = Activity.last
          assert_equal charter, activity.subject
          assert_equal admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_citizens_charters.charter.commitment_published", activity.action
        end

        def test_update_commitment_error
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                fill_in "commitment_title_translations_en", with: ""
                fill_in "commitment_description_translations_en", with: ""
                click_link "ES"
                fill_in "commitment_title_translations_es", with: ""
                fill_in "commitment_description_translations_es", with: ""

                click_button "Update"

                assert has_alert?("can't be blank")
              end
            end
          end
        end
      end
    end
  end
end
