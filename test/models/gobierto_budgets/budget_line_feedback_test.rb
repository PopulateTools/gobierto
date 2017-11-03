require "test_helper"

class GobiertoBudgets::BudgetLineFeedbackTest < ActiveSupport::TestCase
  def budget_line_feedback
    @budget_line_feedback ||= GobiertoBudgets::BudgetLineFeedback.new
  end

  def test_valid
    assert budget_line_feedback.valid?
  end
end
