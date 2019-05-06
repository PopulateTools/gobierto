# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationResponsesTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = edit_admin_budget_consultation_path(consultation)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def consultation
        @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
      end

      def test_consultation_search_id
        with(js: true) do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              assert has_content?("Responses until now: 2")
              click_link "Check if an ID has responded"

              # Document number not in the census: susan
              fill_in "document_number", with: "00000000C"
              click_button "Search"
              assert has_content?("This ID is not in the census")

              # Document number already responded: dennis
              click_link "Search another"
              fill_in "document_number", with: "00000000A"
              click_button "Search"
              assert has_content?("This ID has participated already")

              # Document number not responsed: peter
              click_link "Search another"
              fill_in "document_number", with: "00000000D"
              click_button "Search"
              assert has_content?("This ID hasn't responded yet")
            end
          end
        end
      end

      def test_delete_response
        with(js: true) do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              assert has_content?("Responses until now: 2")
              click_link "Check if an ID has responded"
              # Document number already responded: dennis
              fill_in "document_number", with: "00000000A"
              click_button "Search"
              assert has_content?("This ID has participated already")
              page.accept_confirm do
                click_link "Do you want to remove this participation and create a new one?"
              end
              assert has_content?("Responses until now: 1")

              activity = Activity.last
              assert_equal consultation, activity.recipient
              assert_equal admin, activity.author
              assert_equal "gobierto_budget_consultations.consultation_response_deleted", activity.action
              assert_equal "GobiertoBudgetConsultations::ConsultationResponse", activity.subject_type
              assert activity.admin_activity
              assert_equal site.id, activity.site_id
            end
          end
        end
      end

      def test_add_new_response
        with(js: true) do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              assert has_content?("Responses until now: 2")
              click_link "Check if an ID has responded"
              # Document number already responded: dennis
              fill_in "document_number", with: "00000000D"
              click_button "Search"
              assert has_content?("This ID hasn't responded yet")
              click_link "Add a participation to this ID"

              assert has_content?("Add response")

              item1 = gobierto_budget_consultations_consultation_items(:madrid_sports_facilities)
              item2 = gobierto_budget_consultations_consultation_items(:madrid_civil_protection)

              # User information fields
              select "1992", from: :consultation_response_date_of_birth_1i
              select "January", from: :consultation_response_date_of_birth_2i
              select "1", from: :consultation_response_date_of_birth_3i
              page.find("#consultation_response_gender_male", visible: false).trigger("click")
              select "Center", from: "Districts"
              fill_in "Association", with: "Asociación Vecinos Arganzuela"
              fill_in "Bio", with: "My short bio"

              page.find("#consultation_response_selected_options_#{item1.id}_5", visible: false).trigger("click")
              page.find("#consultation_response_selected_options_#{item2.id}_5", visible: false).trigger("click")
              click_button "Create"

              assert has_alert?("Consultation couldn't be saved. Please, review the responses and try again")

              page.find("#consultation_response_selected_options_#{item1.id}_0", visible: false).trigger("click")
              page.find("#consultation_response_selected_options_#{item2.id}_-5", visible: false).trigger("click")
              select "Center", from: "Districts"
              fill_in "Association", with: "Asociación Vecinos Arganzuela"
              fill_in "Bio", with: "My short bio"

              click_button "Create"

              assert has_message?("Response created successfully")
              assert has_content?("Responses until now: 3")

              activity = Activity.last
              assert_equal consultation, activity.recipient
              assert_equal admin, activity.author
              assert_equal "gobierto_budget_consultations.consultation_response_created", activity.action
              assert_equal "GobiertoBudgetConsultations::ConsultationResponse", activity.subject_type
              assert activity.admin_activity
              assert_equal site.id, activity.site_id
            end
          end
        end
      end

      def test_add_new_response_without_user_information
        with(js: true) do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              assert has_content?("Responses until now: 2")
              click_link "Check if an ID has responded"
              # Document number already responded: dennis
              fill_in "document_number", with: "00000000D"
              click_button "Search"
              assert has_content?("This ID hasn't responded yet")
              click_link "Add a participation to this ID"

              assert has_content?("Add response")

              item1 = gobierto_budget_consultations_consultation_items(:madrid_sports_facilities)
              item2 = gobierto_budget_consultations_consultation_items(:madrid_civil_protection)

              # Don't fill user custom fields

              page.find("#consultation_response_selected_options_#{item1.id}_5", visible: false).trigger("click")
              page.find("#consultation_response_selected_options_#{item2.id}_5", visible: false).trigger("click")
              click_button "Create"

              assert has_alert?("Consultation couldn't be saved. Please, review the responses and try again")

              page.find("#consultation_response_selected_options_#{item1.id}_0", visible: false).trigger("click")
              page.find("#consultation_response_selected_options_#{item2.id}_-5", visible: false).trigger("click")
              select "Center", from: "Districts"
              fill_in "Association", with: "Asociación Vecinos Arganzuela"
              fill_in "Bio", with: "My short bio"

              click_button "Create"

              assert has_message?("Response created successfully")
              assert has_content?("Responses until now: 3")

              activity = Activity.last
              assert_equal consultation, activity.recipient
              assert_equal admin, activity.author
              assert_equal "gobierto_budget_consultations.consultation_response_created", activity.action
              assert_equal "GobiertoBudgetConsultations::ConsultationResponse", activity.subject_type
              assert activity.admin_activity
              assert_equal site.id, activity.site_id
            end
          end
        end
      end
    end
  end
end
