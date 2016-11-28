require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationTest < ActiveSupport::TestCase
    def consultation
      @consultation ||= gobierto_budget_consultations_consultations(:madrid_open)
    end

    def test_valid
      assert consultation.valid?
    end

    def test_open_in_range
      consultation.visibility_level = "active"
      consultation.opens_on = Date.today
      consultation.closes_on = Date.tomorrow

      assert consultation.open?
    end

    def test_open_out_of_range
      consultation.visibility_level = "active"
      consultation.opens_on = Date.tomorrow
      consultation.closes_on = Date.tomorrow

      refute consultation.open?
    end

    def test_open_with_draft_visibility_level
      consultation.visibility_level = "draft"
      consultation.opens_on = Date.today
      consultation.closes_on = Date.tomorrow

      refute consultation.open?
    end
  end
end
