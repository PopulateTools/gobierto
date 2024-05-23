# frozen_string_literal: true

require "test_helper"

module GobiertoBudgets
  class BudgetLineTest < ActiveSupport::TestCase
    def site
      @site ||= sites(:madrid)
    end

    def category_with_name_translated
      @category_with_name_translated ||= gobierto_budgets_categories(:economic_1_i)
    end

    def category_with_decription_translated
      @category_with_decription_translated||= gobierto_budgets_categories(:economic_1_g)
    end

    def test_name
      I18n.with_locale(:es) do
        assert_equal "Impuestos directos (custom, only spanish translation)", category_with_name_translated.name
      end
      I18n.with_locale(:en) do
        assert_equal category_with_name_translated.send(:default_name), category_with_name_translated.name
      end
      I18n.with_locale(:ca) do
        assert_equal "Impostos directes", category_with_name_translated.name
      end
    end

    def test_description
      I18n.with_locale(:es) do
        assert_equal "Los gastos de personal son... (custom, translated)", category_with_decription_translated.description
      end
      I18n.with_locale(:en) do
        assert_equal "Personal expenses are... (custom, translated)", category_with_decription_translated.description
      end
      I18n.with_locale(:ca) do
        assert_equal category_with_decription_translated.send(:default_description), category_with_decription_translated.description
      end
    end
  end
end
