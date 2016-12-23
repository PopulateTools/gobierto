require "test_helper"
require "support/populate_data_helpers"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationItemCreateTest < ActionDispatch::IntegrationTest
      include PopulateDataHelpers

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

      def test_consultation_item_create
        with_signed_in_admin(admin) do
          with_current_site(site) do
            with_stubbed_budget_line_collection do
              visit @path

              within "form.new_consultation_item" do
                fill_in "consultation_item_budget_line_name", with: populate_data_budget_line_summary[:name]
                fill_in "consultation_item_title", with: populate_data_budget_line_summary[:name]
                fill_in "consultation_item_budget_line_amount", with: populate_data_budget_line_summary[:amount]
                fill_in "consultation_item_description", with: "ConsultationItem Description"

                # Simulate Budget line selection in user control
                find("#consultation_item_budget_line_id", visible: false).set(populate_data_budget_line_summary[:name])

                click_button "Create Budget line"
              end

              assert has_message?("Consultation item was successfully created")
            end
          end
        end
      end
    end
  end
end
