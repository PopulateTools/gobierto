class GobiertoBudgets::BudgetsController < GobiertoBudgets::ApplicationController
  before_action :load_place
  before_action :load_year, except: [:guide, :export]

  def index
    @kind = GobiertoBudgets::BudgetLine::INCOME
    @area_name = GobiertoBudgets::EconomicArea.area_name
    @interesting_area = GobiertoBudgets::FunctionalArea.area_name

    @site_stats = GobiertoBudgets::SiteStats.new site: @site, year: @year

    @top_income_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(site: current_site, year: @year, place: @site.place, kind: GobiertoBudgets::BudgetLine::INCOME).all
    @top_expense_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(site: current_site, year: @year, place: @site.place, kind: GobiertoBudgets::BudgetLine::EXPENSE).all
    @place_budget_lines = GobiertoBudgets::BudgetLine.all(where: { site: current_site, place: @place, level: 1, year: @year, kind: @kind, area_name: @area_name })
    @interesting_expenses = GobiertoBudgets::BudgetLine.all(where: { site: current_site, place: @place, level: 2, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, area_name: @interesting_area })

    @sample_budget_lines = (@top_income_budget_lines + @top_expense_budget_lines).sample(3)

    @budgets_data_updated_at = @site_stats.budgets_data_updated_at
    @budgets_execution_summary = @site_stats.budgets_execution_summary

    @any_custom_income_budget_lines  = GobiertoBudgets::BudgetLine.any_data?(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::INCOME, area: GobiertoBudgets::CustomArea)
    @any_custom_expense_budget_lines = GobiertoBudgets::BudgetLine.any_data?(site: current_site, year: @year, kind: GobiertoBudgets::BudgetLine::EXPENSE, area: GobiertoBudgets::CustomArea)
  end

  def export
    year = params[:year].to_i

    presenter = GobiertoBudgets::BudgetLineExportPresenter
    indexes = presenter::INDEX_KEYS

    place_budget_lines = []
    GobiertoBudgets::BudgetLine.all_kinds. each do |kind|
      GobiertoBudgets::BudgetArea.all_areas.each do |area|
        indexes.each do |index, attribute|
          if area.available_kinds.include?(kind)
            index_budget_lines = GobiertoBudgets::BudgetLine.all(where: { year: year,
                                                                          site: current_site,
                                                                          place: @place,
                                                                          area_name: area.area_name,
                                                                          kind: kind,
                                                                          index: index },
                                                                 include: [:index],
                                                                 presenter: presenter)
            index_budget_lines.each do |line|
              if idx = place_budget_lines.index { |global_line| global_line.id == line.id }
                place_budget_lines[idx].merge!(line)
              else
                place_budget_lines << line
              end
            end
          end
        end
      end
    end

    respond_to do |format|
      format.json { render json: place_budget_lines }
      format.csv { render csv: GobiertoExports::CSVRenderer.new(place_budget_lines).to_csv, filename: "budget_lines_#{year}" }
    end
  end

  def guide
    @year = GobiertoBudgets::SearchEngineConfiguration::Year.last
    @site_stats = GobiertoBudgets::SiteStats.new site: @site, year: @year
  end

  private

  def load_place
    @place = @site.place
    render_404 and return if @place.nil?
  end

  def load_year
    if params[:year].nil?
      redirect_to gobierto_budgets_budgets_path(GobiertoBudgets::SearchEngineConfiguration::Year.last)
    else
      @year = params[:year].to_i
    end
  end

end
