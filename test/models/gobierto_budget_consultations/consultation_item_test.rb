require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationItemTest < ActiveSupport::TestCase
    def consultation_item
      @consultation_item ||= gobierto_budget_consultations_consultation_items(:madrid_sports_facilities)
    end

    def test_valid
      assert consultation_item.valid?
    end
  end
end
