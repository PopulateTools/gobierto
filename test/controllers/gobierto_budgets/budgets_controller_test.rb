# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::BudgetsControllerTest < GobiertoControllerTest
  def site
    @site ||= sites(:madrid)
  end

  def setup
    super
    Rails.cache.clear
  end

  def test_index_looks_up_the_last_year_with_data_once
    GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.expects(:last_year_with_data).once.returns(2020)

    # Madrid has budgets elaboration enabled, so the default year is the previous one
    with_current_site(site) do
      2.times do
        get gobierto_budgets_budgets_path
        assert_redirected_to gobierto_budgets_budgets_path(2019)
      end
    end
  end
end
