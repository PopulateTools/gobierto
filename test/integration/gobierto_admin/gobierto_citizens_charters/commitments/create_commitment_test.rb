# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Commitments
      class CreateCommitmentTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = new_admin_citizens_charters_charter_commitment_path(charter)
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
          @charter ||= gobierto_citizens_charters_charters(:teleassistance_charter)
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

        def test_create_commitment_errors
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                click_button "Create"

                assert has_alert?("can't be blank")
              end
            end
          end
        end

        def test_create_commitment
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                fill_in "commitment_title_translations_en", with: "Internet availability"
                fill_in "commitment_description_translations_en", with: "There must be at least a device connected to Internet"

                click_link "ES"
                fill_in "commitment_title_translations_es", with: "Disponibilidad de Internet"
                fill_in "commitment_description_translations_es", with: "Debe haber al menos un dispositivo conectado a Internet"

                within ".widget_save" do
                  find("label", text: "Published").click
                end

                click_button "Create"

                assert has_message?("The indicator has been correctly created.")

                new_commitment = ::GobiertoCitizensCharters::Commitment.last

                assert_equal charter.id, new_commitment.charter_id

                within "#commitment-item-#{ new_commitment.id }" do
                  find("i.fa-edit").click
                end

                assert has_field?("commitment_title_translations_en", with: "Internet availability")
                assert has_field?("commitment_description_translations_en", with: "There must be at least a device connected to Internet")
                click_link "ES"
                assert has_field?("commitment_title_translations_es", with: "Disponibilidad de Internet")
                assert has_field?("commitment_description_translations_es", with: "Debe haber al menos un dispositivo conectado a Internet")
              end
            end
          end

          activity = Activity.last
          assert_equal charter, activity.subject
          assert_equal admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_citizens_charters.charter.commitment_created", activity.action
        end
      end
    end
  end
end
