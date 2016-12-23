require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationParticipationShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_budget_consultations_consultation_participation_path(consultation_response.sharing_token)
    end

    def consultation_response
      @consultation_response ||= gobierto_budget_consultations_consultation_responses(:dennis_madrid_open)
    end

    def consultation
      @consultation ||= consultation_response.consultation
    end

    def site
      @site ||= consultation.site
    end

    def test_consultation_participation_show
      with_current_site(site) do
        visit @path

        assert has_selector?("#consultation_participation_wrapper")

        within "table.budget-line_list" do
          consultation_response.consultation_items.each do |consultation_item|
            assert has_selector?("td.budget-line_title", text: consultation_item.item_title)
            assert has_selector?(
              ".button_marker.active",
              text: I18n.t("gobierto_budget_consultations.consultation_items.options.short.#{consultation_item.selected_option_label}")
            )
          end
        end
      end
    end
  end
end
