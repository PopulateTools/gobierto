require "test_helper"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationUpdateTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = edit_admin_budget_consultation_path(consultation)
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

      def test_consultation_update
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "form.edit_consultation" do
              fill_in "consultation_title", with: "Consultation Title"
              fill_in "consultation_description", with: "Consultation Description"
              fill_in "consultation_opening_date_range", with: "2016-01-01 - 2016-12-01"

              within ".widget_save" do
                choose "Draft"
              end

              click_button "Update"
            end

            assert has_message?("Consultation was successfully updated")

            within "form.edit_consultation" do
              assert has_field?("consultation_title", with: "Consultation Title")
              assert has_field?("consultation_description", with: "Consultation Description")
              assert has_field?("consultation_opening_date_range", with: "2016-01-01 - 2016-12-01")

              within ".widget_save" do
                assert has_checked_field?("Draft")
              end
            end
          end
        end
      end
    end
  end
end
