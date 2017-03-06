require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationShowTest < ActionDispatch::IntegrationTest
    include ActionView::Helpers::TranslationHelper

    def setup
      super
      @path = gobierto_budget_consultations_consultation_path(consultation)
      @past_consultation_path = gobierto_budget_consultations_consultation_path(past_consultation)
      @upcoming_consultation_path = gobierto_budget_consultations_consultation_path(upcoming_consultation)
    end

    def consultation
      @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
    end

    def past_consultation
      @past_consultation ||= gobierto_budget_consultations_consultations(:madrid_past)
    end

    def upcoming_consultation
      @upcoming_consultation ||= gobierto_budget_consultations_consultations(:madrid_upcoming)
    end

    def site
      @site ||= consultation.site
    end

    def user
      @user ||= users(:dennis)
    end

    def user_verified
      @user_verified ||= users(:peter)
    end

    def user_no_verified
      @user_no_verified ||= users(:susan)
    end

    def test_consultation_show
      with_current_site(site) do
        visit @path

        assert has_link?("Do you want to opinate?")
      end
    end

    def test_past_consultation_show
      with_current_site(site) do
        visit @past_consultation_path

        refute has_link?("Do you want to opinate?")
        assert has_content?("Sorry, this consultation is closed")
      end
    end

    def test_upcoming_consultation_show
      with_current_site(site) do
        visit @upcoming_consultation_path

        refute has_link?("Do you want to opinate?")
        assert has_content?("You'll be able to participate since the #{l(upcoming_consultation.opens_on, format: :long).downcase}")
      end
    end

    def test_draft_consultation_show
      consultation.draft!

      with_current_site(site) do
        with_signed_in_user(user) do
          visit @path

          refute has_link?("Participa en la consulta")
        end
      end
    end

    def test_show_summary_and_items_without_session
      with_current_site(site) do
        visit @path

        assert has_link?("Do you want to opinate?")

        click_link "Do you want to opinate?"

        assert has_selector?(".consultation-title", text: "Inversión en Instalaciones Deportivas")
        assert has_content?("10€")
        assert has_selector?(".consultation-title", text: "Inversión en Bomberos y Protección Civil")
        assert has_content?("40€")

        click_link "Start"

        assert has_message?("The participation in this consultation is reserved to people registered in Madrid.")
      end
    end

    def test_show_summary_and_items_with_session_already_participated
      with_current_site(site) do
        with_signed_in_user(user) do
          visit @path

          assert has_message?("You already replied to this consultation")
        end
      end
    end

    def test_show_summary_and_items_with_session_no_verified
      with_current_site(site) do
        with_signed_in_user(user_no_verified) do
          visit @path

          assert has_link?("Do you want to opinate?")

          click_link "Do you want to opinate?"

          assert has_selector?(".consultation-title", text: "Inversión en Instalaciones Deportivas")
          assert has_content?("10€")
          assert has_selector?(".consultation-title", text: "Inversión en Bomberos y Protección Civil")
          assert has_content?("40€")

          click_link "Start"

          assert has_message?("The process in which you want to participate requires to verify your register in")
        end
      end
    end

    def test_show_summary_and_items_with_session_already_verified
      with_javascript do
        with_current_site(site) do
          with_signed_in_user(user_verified) do
            visit @path

            assert has_link?("Do you want to opinate?")

            click_link "Do you want to opinate?"

            assert has_selector?(".consultation-title", text: "Inversión en Instalaciones Deportivas")
            assert has_content?("10€")
            assert has_selector?(".consultation-title", text: "Inversión en Bomberos y Protección Civil")
            assert has_content?("40€")

            click_link "Start"

            assert has_selector?(".consultation-title", text: "Inversión en Instalaciones Deportivas")
          end
        end
      end
    end
  end
end
