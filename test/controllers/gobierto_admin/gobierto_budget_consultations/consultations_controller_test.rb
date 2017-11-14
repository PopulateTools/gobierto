# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    class ConsultationsControllerTest < GobiertoControllerTest
      def consultation
        @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
      end

      def admin
        @admin ||= gobierto_admin_admins(:natasha)
      end

      def setup
        super
        sign_in_admin(admin)
      end

      def teardown
        super
        sign_out_admin
      end

      def valid_consultation_params
        {
          consultation: {
            title: consultation.title,
            description: consultation.description,
            opening_date_range: "2016-01-01 - 2016-12-01"
          }
        }
      end

      def test_edit
        get edit_admin_budget_consultation_url(consultation)
        assert_response :success
      end

      def test_update
        patch admin_budget_consultation_url(consultation), params: valid_consultation_params
        assert_redirected_to edit_admin_budget_consultation_path(consultation)
      end
    end
  end
end
