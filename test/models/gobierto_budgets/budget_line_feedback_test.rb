# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::BudgetLineFeedbackTest < ActiveSupport::TestCase
  def site
    @site ||= sites(:madrid)
  end

  def budget_line_feedback
    @budget_line_feedback ||= GobiertoBudgets::BudgetLineFeedback.new(site: site)
  end

  def test_valid
    assert budget_line_feedback.valid?
  end
end
