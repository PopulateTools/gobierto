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

  def test_export
    csv = @subject.export(consultation)
    assert_equal csv, <<~CSV
      id,age,gender,location,question,answer
      692345489,36,male,,Pavimentación de vías públicas,-5
      692345489,36,male,,Inversión en Instalaciones Deportivas,5
      112679343,,,,Pavimentación de vías públicas,5
      112679343,,,,Inversión en Instalaciones Deportivas,5
CSV
  end
end
