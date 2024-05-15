# frozen_string_literal: true

require "hashie/mash"

module GobiertoBudgets
  class SiteStats

    attr_accessor(
      :organization_id,
      :previous_year,
      :site,
      :year
    )

    def initialize(options)
      @site = options.fetch :site
      @organization_id = site.organization_id
      @year = options.fetch(:year).to_i
      @previous_year = year - 1
      @data = { debt: {}, population: {} }
    end

    def population_data?
      @population_data ||= has_available?(:population)
    end

    def debt_data?
      @debt_data ||= has_available?(:debt)
    end

    def budgets_data_updated_at
      @site.activities.where(action: "gobierto_budgets.budgets_updated")
        .order(created_at: :desc)
        .limit(1)
        .pluck(:created_at)
        .first
    end

    def providers_data_updated_at
      @site.activities.where(action: "gobierto_budgets.providers_updated")
        .order(created_at: :desc)
        .limit(1)
        .pluck(:created_at)
        .first
    end

    def has_data?(variable, year)
      r = send(variable, year)
      r.present? && r != 0
    end

    def total_budget(params = {})
      GobiertoBudgets::BudgetTotal.budgeted_for(*budget_total_params(params).values)
    end

    def total_budget_updated(params = {})
      GobiertoBudgets::BudgetTotal.budgeted_updated_for(
        budget_total_params(params).merge(fallback: params[:fallback])
      )
    end

    def total_budget_per_inhabitant(params = {})
      amount = total_budget(params)

      return nil unless amount

      (amount.to_f / population_with_fallback(params[:requested_year] || year)).to_f
    end

    def total_budget_per_inhabitant_updated(params = {})
      amount = total_budget_updated(params)

      return nil unless amount

      (amount.to_f / population_with_fallback(params[:requested_year] || year)).to_f
    end

    def total_income_budget(params = {})
      total_budget(params.merge(kind: BudgetLine::INCOME))
    end

    def total_income_budget_updated(params = {})
      total_budget_updated(params.merge(kind: BudgetLine::INCOME))
    end

    def total_income_budget_per_inhabitant(params = {})
      total_income_budget(params).to_f / population_with_fallback(year)
    end

    def total_budget_executed(params = {})
      GobiertoBudgets::BudgetTotal.execution_for(*budget_total_params(params).values)
    end

    def total_income_budget_executed(params = {})
      total_budget_executed(params.merge(kind: BudgetLine::INCOME))
    end

    def total_budget_executed_percentage(requested_year = year)
      execution_percentage(
        total_budget_updated(year: requested_year, fallback: true),
        total_budget_executed(year: requested_year)
      )
    end

    def debt(requested_year = year)
      @data[:debt][requested_year] ||= SearchEngine.client.get(
        index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Data.index,
        id: [@site.organization_id, requested_year, GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Data.type_debt].join("/")
      )["_source"]["value"]

      @data[:debt][requested_year]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def population(requested_year = year)
      @data[:population][requested_year] ||= SearchEngine.client.get(
        index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Data.index,
        id: [organization_id, requested_year, GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Data.type_population].join("/")
      )["_source"]["value"]

      @data[:population][requested_year]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def net_savings(requested_year = year)
      total_income = 0
      (1..5).each do |code|
        total_income += get_income_budget_line(requested_year, code)
      end
      return 0 if total_income == 0

      total_expense = 0
      (1..5).each do |code|
        total_expense += get_expense_budget_line(requested_year, code)
      end

      return (total_income - total_expense - get_expense_budget_line(requested_year, 9)).round(2)
    end

    def debt_level(requested_year = year)
      debt = debt(requested_year) || debt(requested_year - 1) || debt(requested_year - 2)
      return nil if debt.nil?

      total_income = 0
      (1..5).each do |code|
        total_income += get_income_budget_line(requested_year, code)
      end

      return 0 if total_income == 0
      ((debt / total_income) * 100).round(2)
    end

    def auto_funding(requested_year = year)
      income1 = 0
      (1..3).each do |code|
        income1 += get_income_budget_line(requested_year, code)
      end

      income2 = 0
      (1..5).each do |code|
        income2 += get_income_budget_line(requested_year, code)
      end
      return 0 if income2 == 0

      ((income1 / income2) * 100).round(2)
    end

    def latest_available(variable, requested_year = year)
      value = {}
      requested_year.downto(GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.first).each do |y|
        if has_data?(variable, y)
          value = { value: send(variable, y), year: y }
          break
        end
      end
      value
    end

    def has_available?(variable)
      (GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.first..GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last).any? do |y|
        has_data?(variable, y)
      end
    end

    def percentage_difference(options)
      year = options.fetch(:year, year)
      variable1 = options.fetch(:variable1)
      variable2 = options.fetch(:variable2, options.fetch(:variable1))
      diff = if variable1 == variable2
               year1 = options.fetch(:year1)
               year2 = options.fetch(:year2)

               if [:total_budget, :total_income_budget, :total_budget_per_inhabitant, :total_income_budget_per_inhabitant].include?(variable1)
                 year1_arg = { year: year1 }
                 year2_arg = { year: year2 }
               else
                 year1_arg = year1
                 year2_arg = year2
               end

               v1 = send(variable1, year1_arg)
               v2 = send(variable1, year2_arg)

               return nil if v1.nil? || v2.nil?

               ((v1.to_f - v2.to_f) / v2.to_f) * 100
             else
               year_arg = if [:total_budget, :total_income_budget, :total_budget_per_inhabitant, :total_income_budget_per_inhabitant].include?(variable1)
                            { year: year }
                          else
                            year
                          end

               v1 = send(variable1, year_arg)
               v2 = send(variable2, year_arg)

               return nil if v1.nil? || v2.nil?
               ((v1.to_f - v2.to_f) / v2.to_f) * 100
      end
      if diff < 0
        direction = I18n.t("gobierto_budgets.budgets.index.less")
        diff *= -1
      else
        direction = I18n.t("gobierto_budgets.budgets.index.more")
      end

      "#{ ActionController::Base.helpers.number_with_precision(diff, precision: 2) } % #{ direction }"
    end

    def main_budget_lines_summary
      main_budget_lines_forecast = BudgetLine.all(where: { kind: BudgetLine::EXPENSE, level: 1, site: @site, year: year, area_name: EconomicArea.area_name })
      main_budget_lines_execution = BudgetLine.all(where: { kind: BudgetLine::EXPENSE, level: 1, site: @site, year: year, area_name: EconomicArea.area_name, index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed })

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
      @budgets_execution_summary ||= begin
        Hashie::Mash.new(
          last_income: {
            budgeted: total_income_budget,
            budgeted_updated: total_income_budget_updated,
            execution: total_income_budget_executed
          },
          last_expenses: {
            budgeted: total_budget,
            budgeted_updated: total_budget_updated,
            execution: total_budget_executed
          },
          expenses_execution_percentage: total_budget_executed_percentage,
          income_execution_percentage: income_execution_percentage,
          expenses_previous_execution_percentage: total_budget_executed_percentage(previous_year),
          income_previous_execution_percentage: income_execution_percentage(previous_year),
          previous_year: previous_year
        )
      end
    end

    private

    def income_execution_percentage(requested_year = year)
      execution_percentage(
        total_income_budget_updated(year: requested_year, fallback: true),
        total_income_budget_executed(year: requested_year)
      )
    end

    def total_budget_per_inhabitant_query(year)
      SearchEngine.client.get(
        index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::TotalBudget.index_forecast,
        id: [@site.organization_id, year, BudgetLine::EXPENSE, GobiertoBudgetsData::GobiertoBudgets::TOTAL_BUDGET_TYPE].join("/")
      )
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def execution_percentage(budgeted_amount, executed_amount)
      ((executed_amount * 100) / budgeted_amount).to_i if budgeted_amount && executed_amount && budgeted_amount != 0
    end

    def get_income_budget_line(year, code)
      kind = GobiertoBudgets::BudgetLine::INCOME
      type = GobiertoBudgets::EconomicArea.area_name
      id = [@site.organization_id, year, code, kind, type].join("/")
      index =  GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast

      result = GobiertoBudgets::SearchEngine.client.get index: index, id: id
      result["_source"]["amount"]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      0
    end

    def get_expense_budget_line(year, code)
      kind = GobiertoBudgets::BudgetLine::EXPENSE
      type = GobiertoBudgets::EconomicArea.area_name
      id = [@site.organization_id, year, code, kind, type].join("/")
      index =  GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast

      result = GobiertoBudgets::SearchEngine.client.get index: index, id: id
      result["_source"]["amount"]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      0
    end

    def budget_total_params(params)
      {
        organization_id: organization_id,
        year: params[:year] || year,
        kind: params[:kind] || BudgetLine::EXPENSE,
        type: GobiertoBudgetsData::GobiertoBudgets::TOTAL_BUDGET_TYPE
      }
    end

    def population_with_fallback(requested_year)
      fallback = 0
      population = nil

      loop do
        population = population(requested_year - fallback)
        fallback += 1 if population.nil?

        break if population.present? || fallback >= 4
      end

      population
    end

  end
end
