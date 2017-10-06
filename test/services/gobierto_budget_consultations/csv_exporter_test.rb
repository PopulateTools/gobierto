# frozen_string_literal: true

require "test_helper"

class GobiertoBudgetConsultations::CsvExporterTest < ActiveSupport::TestCase
  def setup
    super
    @subject = GobiertoBudgetConsultations::CsvExporter
  end

  def consultation
    @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
  end

  def response
    @response ||= gobierto_budget_consultations_consultation_responses(:dennis_madrid_open)
  end

  def test_export
    csv = @subject.export(consultation)
    age = ((Date.today - Date.parse(response.user_information['date_of_birth'])).to_i / 365.0).floor
    assert_equal csv, <<~CSV
      id,age,gender,location,question,answer
      692345489,#{age},male,,Pavimentación de vías públicas,-5
      692345489,#{age},male,,Inversión en Instalaciones Deportivas,5
      112679343,,,,Pavimentación de vías públicas,5
      112679343,,,,Inversión en Instalaciones Deportivas,5
CSV
  end
end
