# frozen_string_literal: true

require 'test_helper'

module GobiertoBudgetConsultations
  class ConsultationsHelperTest < ActionView::TestCase
    def test_budget_amount_to_human
      assert_equal '123,567€', budget_amount_to_human(123_567)
      assert_equal '123,000€', budget_amount_to_human(123_000)
      assert_equal '123,000,000€', budget_amount_to_human(123_000_000)
      assert_equal '1,240,000€', budget_amount_to_human(1_240_000)
    end
  end
end
