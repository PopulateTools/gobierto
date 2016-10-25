class SiteStats
  def initialize(options)
    @site = options.fetch :site
    @place = @site.place
    @year = options.fetch(:year).to_i
    @data = {debt: {},population: {}}
  end

  def has_data?(variable, year)
    r = send(variable, year)
    r.present? && r != 0
  end

  def total_budget_per_inhabitant(year = nil)
    year ||= @year
    total_budget_planned_query(year)['_source']['total_budget_per_inhabitant'].to_f
  end

  def total_income_budget(year = nil)
    year ||= @year
    total_budget_planned_income_query(year)['_source']['total_budget'].to_f
  end

  def total_budget(year = nil)
    year ||= @year
    total_budget_planned_query(year)['_source']['total_budget'].to_f
  end
  alias_method :total_budget_planned, :total_budget

  def total_budget_executed(year = nil)
    year ||= @year
    total_budget_executed_query(year)['_source']['total_budget']
  rescue
    nil
  end

  def debt(year = nil)
    year ||= @year
    @data[:debt][year] ||= GobiertoBudgets::SearchEngine.client.get(index: GobiertoBudgets::SearchEngineConfiguration::Data.index,
      type: GobiertoBudgets::SearchEngineConfiguration::Data.type_debt, id: [@place.id, year].join('/'))['_source']['value'] * 1000
    @data[:debt][year]
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    nil
  end

  def population(year = nil)
    year ||= @year
    @data[:population][year] ||= GobiertoBudgets::SearchEngine.client.get(index: GobiertoBudgets::SearchEngineConfiguration::Data.index,
      type: GobiertoBudgets::SearchEngineConfiguration::Data.type_population, id: [@place.id, year].join('/'))['_source']['value']
    @data[:population][year]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
  end

  def latest_available(variable, year = nil)
    year ||= @year
    value = []
    year.downto(2010).each do |y|
      if has_data?(variable, y)
        value = {value: send(variable,y), year: y}
        break
      end
    end
    value
  end

  def percentage_difference(options)
    year = options.fetch(:year, @year)
    variable1 = options.fetch(:variable1)
    variable2 = options.fetch(:variable2, options.fetch(:variable1))
    diff = if variable1 == variable2
      year1 = options.fetch(:year1)
      year2 = options.fetch(:year2)

      v1 = self.send(variable1, year1)
      v2 = self.send(variable1, year2)
      return nil if v1.nil? || v2.nil?

      ((v1.to_f - v2.to_f)/v2.to_f) * 100
    else
      v1 = self.send(variable1, year)
      v2 = self.send(variable2, year)
      return nil if v1.nil? || v2.nil?
      ((v1.to_f - v2.to_f)/v2.to_f) * 100
    end

    if(diff < 0)
      direction = I18n.t('.gobierto_sites.budgets.index.less')
      diff = diff*-1
    else
      direction = I18n.t('gobierto_sites.budgets.index.more')
    end

    "#{ActionController::Base.helpers.number_with_precision(diff, precision: 2)}% #{direction}"
  end

  private

  def total_budget_planned_query(year)
    GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.index_forecast,
      type: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type, id: [@place.id, year, GobiertoBudgets::BudgetLine::EXPENSE].join('/')
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    nil
  end

  def total_budget_executed_query(year)
    GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.index_executed,
      type: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type, id: [@place.id, year, GobiertoBudgets::BudgetLine::EXPENSE].join('/')
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    nil
  end

  def total_budget_planned_income_query(year)
    GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.index_forecast,
      type: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type, id: [@place.id, year, GobiertoBudgets::BudgetLine::INCOME].join('/')
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    nil
  end

end
