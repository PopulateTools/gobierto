require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationResponseCreateTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = budget_consultation_new_response_path(consultation)
      @closed_path = budget_consultation_new_response_path(closed_consultation)
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
      @user ||= users(:dennis)
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
  end
end
