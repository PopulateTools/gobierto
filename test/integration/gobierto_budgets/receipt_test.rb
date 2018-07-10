# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::ReceiptTest < ActionDispatch::IntegrationTest
  def placed_site
    @placed_site ||= sites(:madrid)
  end

  def organization_site
    @organization_site ||= sites(:organization_wadus)
  end

  def test_greeting
    with_each_current_site(placed_site, organization_site) do |site|
      visit gobierto_budgets_receipt_path

      assert has_content?("Your contribution to #{ site.name }")
    end
  end
end
