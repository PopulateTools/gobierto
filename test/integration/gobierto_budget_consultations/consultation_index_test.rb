require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_budget_consultations_consultations_path
    end

    def active_consultations
      @active_consultations ||= begin
        [gobierto_budget_consultations_consultations(:madrid_open)]
      end
    end

    def past_consultations
      @past_consultations ||= begin
        [gobierto_budget_consultations_consultations(:madrid_past)]
      end
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_consultation_index
      with_current_site(site) do
        visit @path

        assert has_selector?("h1", text: "Consultas activas")

        within ".active-consultations" do
          active_consultations.each do |consultation|
            assert has_link?(consultation.title)
          end
        end

        assert has_selector?("h2", text: "Consultas anteriores")

        within ".past-consultations" do
          past_consultations.each do |consultation|
            assert has_link?(consultation.title)
          end
        end
      end
    end
  end
end
