require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationsHelperTest < ActionView::TestCase
    def test_budget_amount_to_human
      assert_equal "123,567€", budget_amount_to_human(123567)
      assert_equal "123,000€", budget_amount_to_human(123000)
      assert_equal "123,000,000€", budget_amount_to_human(123000000)
      assert_equal "1,240,000€", budget_amount_to_human(1240000)
    end
  end
end
