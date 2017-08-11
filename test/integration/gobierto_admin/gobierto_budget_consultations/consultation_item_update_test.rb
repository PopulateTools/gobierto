# frozen_string_literal: true

require "test_helper"
require "support/populate_data_helpers"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationItemUpdateTest < ActionDispatch::IntegrationTest
      include PopulateDataHelpers

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

      def test_consultation_item_update
        with_signed_in_admin(admin) do
          with_current_site(site) do
            with_stubbed_budget_line_collection do
              visit @path

              within "form.edit_consultation_item" do
                fill_in "consultation_item_budget_line_name", with: populate_data_budget_line_summary[:name]
                fill_in "consultation_item_title", with: populate_data_budget_line_summary[:name]
                fill_in "consultation_item_budget_line_amount", with: populate_data_budget_line_summary[:amount]
                fill_in "consultation_item_description", with: "ConsultationItem Description"

                # Simulate Budget line selection in user control
                find("#consultation_item_budget_line_id", visible: false).set(populate_data_budget_line_summary[:name])

                click_button "Update"
              end

              assert has_message?("Consultation item was successfully updated")
            end
          end
        end
      end
    end
  end
end
