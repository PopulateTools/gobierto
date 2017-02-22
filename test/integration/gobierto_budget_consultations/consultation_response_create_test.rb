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

    def closed_consultation
      @closed_consultation ||= gobierto_budget_consultations_consultations(:madrid_past)
    end

    def site
      @site ||= consultation.site
    end

    def user
      @user ||= users(:peter)
    end

    def unverified_user
      @unverified_user ||= users(:susan)
    end

    def test_consultation_response_creation_when_not_signed_in
      with_current_site(site) do
        visit @path

        assert has_content?("We need you to sign in to continue.")
      end
    end

    def test_consultation_response_creation_when_user_is_not_verified
      with_current_site(site) do
        with_signed_in_user(unverified_user) do
          visit @path

          assert has_content?("Your account is not yet verified.")
        end
      end
    end

    def test_consultation_response_creation_when_consultation_is_closed
      with_current_site(site) do
        with_signed_in_user(user) do
          visit @closed_path

          assert has_content?("This consultation doesn't allow participations.")
        end
      end
    end

    def test_consultation_response_creation_workflow
      with_javascript do
        with_current_site(site) do
          with_signed_in_user(user) do
            visit @path

            page.find(".consultation-title", text: "Inversión en Instalaciones Deportivas").trigger('click')
            page.find("button", text: "Reduce").trigger('click')
            assert_equal "Surplus", page.all(".budget-figure").last.text
            sleep 2
            page.find("button", text: "Increase").trigger('click')
            assert_equal "Balanced", page.all(".budget-figure").last.text

            assert page.find("a.budget-next i")['class'].include?("fa-check")
            page.find("a.budget-next").trigger('click')

            assert has_content?("Thanks for your response")
          end
        end
      end
    end

    def test_consultation_response_creation_workflow_deficit
      with_javascript do
        with_current_site(site) do
          with_signed_in_user(user) do
            visit @path

            page.find(".consultation-title", text: "Inversión en Instalaciones Deportivas").trigger('click')
            page.find("button", text: "Increase").trigger('click')
            assert_equal "Deficit", page.all(".budget-figure").last.text
            sleep 2
            page.find("button", text: "Increase").trigger('click')
            assert_equal "Deficit", page.all(".budget-figure").last.text

            assert page.find("a.budget-next i")['class'].include?("fa-times")
            page.find("a.budget-next").trigger('click')

            refute has_content?("Estupendo, muchas gracias por tu aportación")
          end
        end
      end
    end

  end
end
