# frozen_string_literal: true

require "test_helper"
#require_relative "../../../../../test/factories/budget_line_factory"

class BudgetsPluginTest < ActionDispatch::IntegrationTest

  def site
    @site ||= sites(:madrid)
  end

  def admin
    @admin ||= gobierto_admin_admins(:natasha)
  end

  def project
    @project ||= gobierto_plans_nodes(:political_agendas)
  end

  def plan
    @plan ||= gobierto_plans_plans(:strategic_plan)
  end

  def within_plugin(params = nil)
    within("#custom_field_budgets") do
      if params
        within(params) { yield }
      else
        yield
      end
    end
  end

  def seed_budget_lines
    common_args = {
      kind: GobiertoData::GobiertoBudgets::EXPENSE,
      indexes: [:forecast]
    }

    BudgetLineFactory.new(common_args.merge(code: "1", year: 2014, area: GobiertoData::GobiertoBudgets::ECONOMIC_AREA_NAME))
    BudgetLineFactory.new(common_args.merge(code: "2", year: 2015, area: GobiertoData::GobiertoBudgets::ECONOMIC_AREA_NAME))
    BudgetLineFactory.new(common_args.merge(code: "3", year: 2016, area: GobiertoData::GobiertoBudgets::FUNCTIONAL_AREA_NAME))
  end

  def test_show
    seed_budget_lines

    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

      within_plugin do
        assert has_content?("1 - Gastos de personal")
        assert has_content?("123,457")
        assert has_content?("10")
        assert has_content?("12,346")

        assert has_content?("2 - Gastos en bienes corrientes y servicios")
        assert has_content?("15")
        assert has_content?("18,519")

        assert has_content?("3 - Producci")
        assert has_content?("20")
        assert has_content?("24,691")
      end
    end
  end

end
