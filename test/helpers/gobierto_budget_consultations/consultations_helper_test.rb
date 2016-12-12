require "test_helper"

module GobiertoBudgetConsultations
  class ConsultationsHelperTest < ActionView::TestCase
    def test_budget_amount_to_human
      assert_equal "124000", budget_amount_to_human(123567)
      assert_equal "123000", budget_amount_to_human(123000)
      assert_equal "123 M", budget_amount_to_human(123000000)
      assert_equal "1.24 M", budget_amount_to_human(1240000)
    end
  end
end
