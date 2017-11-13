# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoBudgetConsultations
    module Consultations
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
          @exporter_spy = Spy.on(::GobiertoBudgetConsultations::CsvExporter, :export)
        end
        attr_reader :exporter_spy

        def teardown
          super
          sign_out_admin
        end

        def test_show
          get admin_budget_consultation_consultation_reports_url(consultation), params: { format: :csv }
          assert_response :success
          assert exporter_spy.has_been_called?
        end
      end
    end
  end
end
