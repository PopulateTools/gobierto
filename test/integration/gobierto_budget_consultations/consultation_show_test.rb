require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_budget_consultations_consultation_path(consultation)
    end

    def consultation
      @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
    end

    def site
      @site ||= consultation.site
    end

    def test_consultation_show
      with_current_site(site) do
        visit @path

        assert has_selector?("h1", text: consultation.title)
        assert has_selector?(".intro", text: consultation.description.gsub("\n", " ").strip)
        assert has_link?("Participa en la consulta")
      end
    end
  end
end
