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

    def test_consultation_show
      with_current_site(site) do
        visit @path

        assert has_selector?("h1", text: consultation.title)
        assert has_content?(consultation.description.gsub("\n", " ").strip)
        assert has_link?("Participa en la consulta")
      end
    end

    def test_past_consultation_show
      with_current_site(site) do
        visit @past_consultation_path

        refute has_link?("Participa en la consulta")
        assert has_selector?(
          ".feedback-block",
          text: "Lo sentimos, esta consulta está cerrada"
        )
      end
    end

    def test_upcoming_consultation_show
      with_current_site(site) do
        visit @upcoming_consultation_path

        refute has_link?("Participa en la consulta")
        assert has_selector?(
          ".feedback-block",
          text: "Podrás participar en esta consulta a partir del #{l(upcoming_consultation.opens_on, format: :short)}"
        )
      end
    end

    def test_draft_consultation_show
      consultation.draft!

      with_current_site(site) do
        with_signed_in_user(user) do
          visit @path

          refute has_link?("Participa en la consulta")
          assert has_content?("You are not authorized to perform this action.")
        end
      end
    end
  end
end
