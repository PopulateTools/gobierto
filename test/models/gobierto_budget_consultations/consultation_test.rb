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

    def test_calculate_budget_amount
      consultation.budget_amount = 0.0
      assert_equal 0.0, consultation.budget_amount

      consultation_items_total_amount = consultation.consultation_items.sum(:budget_line_amount)

      assert_difference "consultation.budget_amount", consultation_items_total_amount do
        consultation.calculate_budget_amount
      end
    end
  end
end
