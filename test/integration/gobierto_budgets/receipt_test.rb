# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::ReceiptTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = gobierto_budgets_receipt_path
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_greeting
    with_javascript do
      with_current_site(site) do
        visit @path

        assert has_content?("Your contribution to Ayuntamiento de Madrid")
      end
    end
  end
end
