# frozen_string_literal: true

require "hashie/mash"

module GobiertoBudgets
  class SiteStats

    attr_accessor :organization_id

    def initialize(options)
      @site = options.fetch :site
      self.organization_id = @site.organization_id
      @year = options.fetch(:year).to_i
      @data = { debt: {}, population: {} }
    end

    def population_data?
      @population_data ||= has_available?(:population)
    end

    def debt_data?
      @debt_data ||= has_available?(:debt)
    end

    def budgets_data_updated_at
      @site.activities.where("action ~* ?", "gobierto_budgets.budgets_updated")
           .order(created_at: :asc)
           .pluck(:created_at)
           .last
    end

    def providers_data_updated_at
      @site.activities.where("action ~* ?", "gobierto_budgets.providers_updated")
           .order(created_at: :asc)
           .pluck(:created_at)
           .last
    end

    def has_data?(variable, year)
      r = send(variable, year)
      r.present? && r != 0
    end

    def total_budget_per_inhabitant(year = nil, kind = GobiertoBudgets::BudgetLine::EXPENSE)
      year ||= @year
      amount = updated_total_budget.to_f
      population = population(year) || population(year - 1) || population(year - 2)

      (amount / population).to_f
    end

    def total_income_budget(year = nil)
      year ||= @year
      total_budgeted(kind: BudgetLine::INCOME)
    end

    def total_income_budget_updated(year = nil)
      year ||= @year
      updated_total_budget(kind: BudgetLine::INCOME)
    end

    def total_income_budget_per_inhabitant(year = nil)
      year ||= @year
      total_budgeted(kind: BudgetLine::INCOME).to_f / (population(year) || population(year - 1) || population(year - 2)).to_f
    end

    def total_budget(year = nil, kind = GobiertoBudgets::BudgetLine::EXPENSE)
      year ||= @year
      updated_total_budget
    end
    alias total_budget_planned total_budget

    def total_budget_updated(year = nil)
      year ||= @year

      updated_total_budget(year)
    end

    def total_budget_executed(year = nil)
      year ||= @year
      total_execution
    end

    def total_income_budget_executed(year = nil)
      year ||= @year
      total_execution(kind: BudgetLine::INCOME)
    end

    def total_budget_executed_percentage(year = nil)
      execution_percentage(
        updated_total_budget(year: year),
        total_budget_executed(year: year)
      )
    end

    def debt(year = nil)
      year ||= @year
      @data[:debt][year] ||= SearchEngine.client.get(index: SearchEngineConfiguration::Data.index, type: SearchEngineConfiguration::Data.type_debt, id: [@site.organization_id, year].join("/"))["_source"]["value"]
      @data[:debt][year]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def population(year = nil)
      year ||= @year

      @data[:population][year] ||= SearchEngine.client.get(index: SearchEngineConfiguration::Data.index,
                                                           type: SearchEngineConfiguration::Data.type_population, id: [@site.organization_id, year].join("/"))["_source"]["value"]
      @data[:population][year]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def net_savings(year = nil)
      year ||= @year

      total_income = 0
      (1..5).each do |code|
        total_income += get_income_budget_line(year, code)
      end
      return 0 if total_income == 0

      total_expense = 0
      (1..5).each do |code|
        total_expense += get_expense_budget_line(year, code)
      end

      return (total_income - total_expense - get_expense_budget_line(year, 9)).round(2)
    end

    def debt_level(year = nil)
      year ||= @year

      debt = debt(year) || debt(year - 1) || debt(year - 2)
      return nil if debt.nil?

      total_income = 0
      (1..5).each do |code|
        total_income += get_income_budget_line(year, code)
      end

      return 0 if total_income == 0
      ((debt / total_income) * 100).round(2)
    end

    def auto_funding(year = nil)
      year ||= @year

      income1 = 0
      (1..3).each do |code|
        income1 += get_income_budget_line(year, code)
      end

      income2 = 0
      (1..5).each do |code|
        income2 += get_income_budget_line(year, code)
      end
      return 0 if income2 == 0

      ((income1 / income2) * 100).round(2)
    end

    def latest_available(variable, year = nil)
      year ||= @year
      value = {}
      year.downto(SearchEngineConfiguration::Year.first).each do |y|
        if has_data?(variable, y)
          value = { value: send(variable, y), year: y }
          break
        end
      end
      value
    end

    def has_available?(variable)
      (SearchEngineConfiguration::Year.first..SearchEngineConfiguration::Year.last).any? do |y|
        has_data?(variable, y)
      end
    end

    def percentage_difference(options)
      year = options.fetch(:year, @year)
      variable1 = options.fetch(:variable1)
      variable2 = options.fetch(:variable2, options.fetch(:variable1))
      diff = if variable1 == variable2
               year1 = options.fetch(:year1)
               year2 = options.fetch(:year2)

               v1 = send(variable1, year1)
               v2 = send(variable1, year2)
               return nil if v1.nil? || v2.nil?

               ((v1.to_f - v2.to_f) / v2.to_f) * 100
             else
               v1 = send(variable1, year)
               v2 = send(variable2, year)
               return nil if v1.nil? || v2.nil?
               ((v1.to_f - v2.to_f) / v2.to_f) * 100
      end
      total_income = 0
      (1..5).each do |code|
        total_income += get_income_budget_line(year, code)
      end
      return 0 if total_income == 0


      if diff < 0
        direction = I18n.t("gobierto_budgets.budgets.index.less")
        diff *= -1
      else
        direction = I18n.t("gobierto_budgets.budgets.index.more")
      end

      "#{ ActionController::Base.helpers.number_with_precision(diff, precision: 2) } % #{ direction }"
    end

    def main_budget_lines_summary
      main_budget_lines_forecast = BudgetLine.all(where: { kind: BudgetLine::EXPENSE, level: 1, site: @site, year: @year, area_name: EconomicArea.area_name })
      main_budget_lines_execution = BudgetLine.all(where: { kind: BudgetLine::EXPENSE, level: 1, site: @site, year: @year, area_name: EconomicArea.area_name, index: SearchEngineConfiguration::BudgetLine.index_executed })

      main_budget_lines_summary = {}

      main_budget_lines_forecast.each do |budget_line|
        main_budget_lines_summary[budget_line.code] = {
          title: budget_line.name,
          budgeted_amount: budget_line.amount
        }
      end

      main_budget_lines_execution.each do |budget_line|
        executed_amount = budget_line.amount
        next unless main_budget_lines_summary[budget_line.code]
        budgeted_amount = main_budget_lines_summary[budget_line.code][:budgeted_amount]
        main_budget_lines_summary[budget_line.code].merge!(
          executed_amount: executed_amount,
          executed_percentage: (executed_amount * 100 / budgeted_amount).to_i
        )
      end
      main_budget_lines_summary.values
    end

    def budgets_execution_summary
      organization_id = @site.organization_id
      year = @year
      previous_year = year - 1

      previous_expenses_budgeted = updated_total_budget(year: previous_year) || total_budgeted
      previous_income_budgeted   = updated_total_budget(year: previous_year, kind: BudgetLine::INCOME) || total_budgeted(kind: BudgetLine::INCOME)
      previous_expenses_execution = total_execution(year: previous_year)
      previous_income_execution   = total_execution(year: previous_year, kind: BudgetLine::INCOME)

      result = Hashie::Mash.new(
        last_income: {
          budgeted: total_budgeted(kind: BudgetLine::INCOME),
          budgeted_updated: updated_total_budget(kind: BudgetLine::INCOME),
          execution: total_execution(kind: BudgetLine::INCOME)
        },
        last_expenses: {
          budgeted: total_budgeted,
          budgeted_updated: updated_total_budget,
          execution: total_execution
        },
        expenses_previous_execution_percentage: execution_percentage(previous_expenses_budgeted, previous_expenses_execution),
        income_previous_execution_percentage:   execution_percentage(previous_income_budgeted, previous_income_execution),
        previous_year: previous_year
      )

      result.merge(
        expenses_execution_percentage: execution_percentage(result.last_expenses.budgeted, result.last_expenses.execution),
        income_execution_percentage: execution_percentage(result.last_income.budgeted, result.last_income.execution)
      )
    end

    private

    def total_budget_per_inhabitant_query(year)
      SearchEngine.client.get(
        index: SearchEngineConfiguration::TotalBudget.index_forecast,
        type: SearchEngineConfiguration::TotalBudget.type,
        id: [@site.organization_id, year, BudgetLine::EXPENSE].join("/")
      )
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def execution_percentage(budgeted_amount, executed_amount)
      ((executed_amount * 100) / budgeted_amount).to_i if budgeted_amount && executed_amount && budgeted_amount != 0
    end

    def get_income_budget_line(year, code)
      kind = GobiertoBudgets::BudgetLine::INCOME
      id = [@site.organization_id, year, code, kind].join("/")
      index = GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast
      type = GobiertoBudgets::EconomicArea.area_name

      result = GobiertoBudgets::SearchEngine.client.get index: index, type: type, id: id
      result["_source"]["amount"]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      0
    end

    def get_expense_budget_line(year, code)
      kind = GobiertoBudgets::BudgetLine::EXPENSE
      id = [@site.organization_id, year, code, kind].join("/")
      index = GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast
      type = GobiertoBudgets::EconomicArea.area_name

      result = GobiertoBudgets::SearchEngine.client.get index: index, type: type, id: id
      result["_source"]["amount"]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      0
    end

    def updated_total_budget(params = {})
      GobiertoBudgets::BudgetTotal.budgeted_updated_for(
        budget_total_params(params).merge(fallback_to_initial_estimate: true)
      )
    end

    def total_budgeted(params = {})
      GobiertoBudgets::BudgetTotal.budgeted_for(*budget_total_params(params).values)
    end

    def total_execution(params = {})
      GobiertoBudgets::BudgetTotal.execution_for(*budget_total_params(params).values)
    end

    def budget_total_params(params)
      {
        organization_id: organization_id,
        year: params[:year] || @year,
        kind: params[:kind] || BudgetLine::EXPENSE
      }
    end

  end
end
