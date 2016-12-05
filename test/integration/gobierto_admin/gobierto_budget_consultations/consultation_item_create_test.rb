require "test_helper"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationItemCreateTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = new_admin_budget_consultation_consultation_item_path(consultation)
      end

      def consultation
        @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
      end

      def admin
        @admin ||= consultation.admin
      end

      def site
        @site ||= consultation.site
      end

      def budget_line
        # TODO. Mock this response.
        #
        OpenStruct.new(
          id: "9208.0/2016-01-01/p/e/f/151",
          name: "Pavimentación de vías públicas",
          amount: "100000"
        )
      end

      def test_consultation_item_create
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "form.new_consultation_item" do
              select budget_line.name, from: "consultation_item_budget_line_id"

              fill_in "consultation_item_title", with: budget_line.name
              fill_in "consultation_item_budget_line_amount", with: budget_line.amount
              fill_in "consultation_item_description", with: "ConsultationItem Description"

              click_button "Create Budget line"
            end

            assert has_content?("Consultation item was successfully created.")
          end
        end
      end
    end
  end
end
