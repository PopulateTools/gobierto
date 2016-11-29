require "test_helper"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationItemUpdateTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = edit_admin_budget_consultation_consultation_item_path(consultation, consultation_item)
      end

      def consultation_item
        @consultation_item ||= gobierto_budget_consultations_consultation_items(:madrid_sports_facilities)
      end

      def consultation
        @consultation ||= consultation_item.consultation
      end

      def admin
        @admin ||= consultation.admin
      end

      def site
        @site ||= consultation.site
      end

      def budget_line_label
        "Pavimentación de vías públicas (10.000 EUR)"
      end

      def test_consultation_item_update
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "form.edit_consultation_item" do
              select budget_line_label, from: "consultation_item_budget_line_id"

              fill_in "consultation_item_title", with: "ConsultationItem Title"
              fill_in "consultation_item_description", with: "ConsultationItem Description"

              click_button "Update Budget line"
            end

            assert has_content?("Consultation item was successfully updated.")
          end
        end
      end
    end
  end
end
