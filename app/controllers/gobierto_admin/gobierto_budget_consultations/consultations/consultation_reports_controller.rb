# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoBudgetConsultations
    module Consultations
      class ConsultationReportsController < Consultations::BaseController
        def show
          respond_to do |format|
            format.csv do
              send_data ::GobiertoBudgetConsultations::CsvExporter.export(@consultation), filename: report_filename
            end
          end
        end

        private

        def report_filename
          "consultation-#{@consultation.id}-responses-#{Date.today}.csv"
        end
      end
    end
  end
end
