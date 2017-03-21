require "test_helper"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationsListTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_budget_consultations_path(consultation)
      end

      def consultation
        @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
      end

      def closed_consultation
        @closed_consultation ||= gobierto_budget_consultations_consultations(:madrid_past)
      end

      def admin
        @admin ||= consultation.admin
      end

      def site
        @site ||= consultation.site
      end

      def test_consultations_list
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            click_link consultation.title
            assert has_selector?("form.edit_consultation")
          end
        end
      end

      def test_visit_closed_consultation
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            click_link closed_consultation.title
            assert has_content?("There weren't respones in this consultation")
          end
        end
      end
    end
  end
end
