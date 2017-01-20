require "test_helper"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationCreateTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = new_admin_budget_consultation_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_consultation_create
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "form.new_consultation" do
              fill_in "consultation_title", with: "Consultation Title"
              fill_in "consultation_description", with: "Consultation Description"
              fill_in "consultation_opening_date_range", with: "2016-01-01 - 2016-12-01"

              within ".consultation-visibility-level-radio-buttons" do
                choose "Published"
              end

              click_button "Create"
            end

            assert has_message?("Consultation was successfully created")

            assert has_selector?("h1", text: "Consultation Title")
            assert has_selector?(".consultation-items-list")
          end
        end
      end
    end
  end
end
