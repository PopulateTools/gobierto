# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::BudgetsExecutionControllerTest < GobiertoControllerTest
  def site
    @site ||= sites(:madrid)
  end

  def year
    @year ||= Date.today.year - 2
  end

  def setup
    super
    Rails.cache.clear
    @perform_caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = true
  end

  def teardown
    ActionController::Base.perform_caching = @perform_caching
    super
  end

  def test_index_is_cached_per_year
    with_current_site(site) do
      get gobierto_budgets_budgets_execution_path(year)
      assert_response :success

      GobiertoBudgets::SearchEngine.expects(:client).never
      get gobierto_budgets_budgets_execution_path(year)
      assert_response :success
    end
  end

  def test_index_cache_depends_on_the_year
    client = GobiertoBudgets::SearchEngine.client

    with_current_site(site) do
      get gobierto_budgets_budgets_execution_path(year)

      GobiertoBudgets::SearchEngine.expects(:client).at_least_once.returns(client)
      get gobierto_budgets_budgets_execution_path(year - 1)
    end
  end
end
