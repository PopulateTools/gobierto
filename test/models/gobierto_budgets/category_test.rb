# frozen_string_literal: true

require "test_helper"

module GobiertoBudgets
  class BudgetLineTest < ActiveSupport::TestCase
    def site
      @site ||= sites(:madrid)
    end

    def category
      @category ||= gobierto_budgets_categories(:economic_1_g)
    end

    def test_name
      I18n.locale = :es
      assert_equal "Gastos de personal (custom, translated)", category.name
      I18n.locale = :en
      assert_equal "Personal expenses (custom, translated)", category.name
      I18n.locale = :ca
      assert_equal category.send(:default_name), category.name
    end

    def test_description
      I18n.locale = :es
      assert_equal "Los gastos de personal son... (custom, translated)", category.description
      I18n.locale = :en
      assert_equal "Personal expenses are... (custom, translated)", category.description
      I18n.locale = :ca
      assert_equal category.send(:default_description), category.description
    end
  end
end
