# frozen_string_literal: true

require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationResponseCreateTest < ActionDispatch::IntegrationTest
    include ActionView::Helpers::NumberHelper

    def setup
      super
      @path = gobierto_budget_consultations_consultation_new_response_path(consultation)
      @closed_path = gobierto_budget_consultations_consultation_new_response_path(closed_consultation)
    end

    def consultation
      @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
    end

    def consultation_not_requiring_balance
      @consultation_not_requiring_balance ||= gobierto_budget_consultations_consultations(:madrid_open_no_balance)
    end

    def closed_consultation
      @closed_consultation ||= gobierto_budget_consultations_consultations(:madrid_past)
    end

    def site
      @site ||= consultation.site
    end

    def user
      @user ||= users(:peter)
    end

    def site_unverified_user
      @site_unverified_user ||= users(:janet)
    end

    def test_consultation_response_creation_when_not_signed_in
      with_current_site(site) do
        visit @path

        assert has_content?("The participation in this consultation is reserved to people registered in Madrid.")
      end
    end

    def test_consultation_response_creation_when_user_is_not_verified
      with_signed_in_user(site_unverified_user) do
        # Force referer detection
        Capybara.current_session.driver.header "Referer", @path
        visit @path

        assert has_content?("The process in which you want to participate requires to verify your register in")

        assert has_content?("Confirm your identity")

        fill_in :user_verification_document_number, with: "00000000D"

        select "1993", from: :user_verification_date_of_birth_1i
        select "January", from: :user_verification_date_of_birth_2i
        select "1", from: :user_verification_date_of_birth_3i

        click_on "Verify"

        assert has_content?("Your identity has been verified successfully")

        assert_equal @path, page.current_path
      end
    end

    def test_consultation_response_creation_when_consultation_is_closed
      with_signed_in_user(user) do
        visit @closed_path

        assert has_content?("This consultation doesn't allow participations.")
      end
    end

    def test_consultation_response_creation_workflow
      with(js: true) do
        with_signed_in_user(user) do
          visit @path

          page.find(".consultation-title", text: "Inversión en Instalaciones Deportivas").trigger("click")
          page.find("button", text: "Reduce").trigger("click")
          assert_equal "Surplus", page.all(".budget-figure").last.text
          sleep 2
          page.find("button", text: "Increase").trigger("click")
          assert_equal "Balanced", page.all(".budget-figure").last.text

          assert page.find("a.budget-next i")["class"].include?("fa-check")
          page.find("a.budget-next").trigger("click")

          assert has_content?("Thanks for your response")
        end
      end
    end

    def test_consultation_response_creation_workflow_deficit_and_balance_required
      with(js: true) do
        with_signed_in_user(user) do
          visit @path

          page.find(".consultation-title", text: "Inversión en Instalaciones Deportivas").trigger("click")
          page.find("button", text: "Increase").trigger("click")
          assert_equal "Deficit", page.all(".budget-figure").last.text
          sleep 2
          page.find("button", text: "Increase").trigger("click")
          assert_equal "Deficit", page.all(".budget-figure").last.text

          assert page.find("a.budget-next i")["class"].include?("fa-times")
          page.find("a.budget-next").trigger("click")

          assert has_no_content?("Estupendo, muchas gracias por tu aportación")
        end
      end
    end

    def test_consultation_response_creation_workflow_deficit_and_balance_not_required
      with(js: true) do
        with_signed_in_user(user) do
          visit gobierto_budget_consultations_consultation_new_response_path(consultation_not_requiring_balance)

          page.find(".consultation-title", text: "Inversión en Instalaciones Deportivas").trigger("click")
          page.find("button", text: "Increase").trigger("click")
          assert_equal "Deficit", page.all(".budget-figure").last.text
          sleep 2
          page.find("button", text: "Increase").trigger("click")
          assert_equal "Deficit", page.all(".budget-figure").last.text
          sleep 2
          assert page.find("a.budget-next i")["class"].include?("fa-check")
          page.find("a.budget-next").trigger("click")

          assert has_content?("Thanks for your response")
        end
      end
    end

    def test_consultation_response_creation_with_login
      with_current_site(site) do
        # Force referer detection
        Capybara.current_session.driver.header "Referer", @path
        visit @path

        assert has_content?("The participation in this consultation is reserved to people registered in Madrid.")

        within("#user-session-form") do
          fill_in :user_session_email, with: user.email
          fill_in :user_session_password, with: "gobierto"

          click_button "Log in"
        end

        assert_equal @path, page.current_path
      end
    end

    def test_consultation_response_creation_with_signup_and_verification
      with_current_site(site) do
        # Force referer detection
        Capybara.current_session.driver.header "Referer", @path
        visit @path

        assert has_content?("The participation in this consultation is reserved to people registered in Madrid.")

        fill_in :user_registration_email, with: "user@email.dev"

        click_on "Let's go"

        assert has_message?("Please check your inbox to confirm your email address")

        unconfirmed_user = User.last
        assert_equal "user@email.dev", unconfirmed_user.email

        visit new_user_confirmations_path(confirmation_token: unconfirmed_user.confirmation_token)

        fill_in :user_confirmation_name, with: "user@email.dev"
        fill_in :user_confirmation_password, with: "wadus"
        fill_in :user_confirmation_password_confirmation, with: "wadus"
        select "1993", from: :user_confirmation_date_of_birth_1i
        select "January", from: :user_confirmation_date_of_birth_2i
        select "1", from: :user_confirmation_date_of_birth_3i
        choose "Male"
        fill_in :user_confirmation_document_number, with: "00000000D"
        select "Center", from: "Districts"
        fill_in "Association", with: "Asociación Vecinos Arganzuela"
        fill_in "Bio", with: "My short bio"

        click_on "Save"

        assert_equal @path, page.current_path
      end
    end
  end
end
