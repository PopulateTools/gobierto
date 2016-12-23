require "test_helper"

class GobiertoBudgets::HomePageTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = gobierto_budgets_site_path(last_year)
  end

  def site
    @site ||= sites(:madrid)
  end

  def last_year
    2016
  end

  def test_greeting
    with_current_site(site) do
      visit @path

      assert has_content?("Relevant data from your municipality")
      assert has_content?(last_year)
    end
  end

  def test_metric_boxes
    with_current_site(site) do
      visit @path

      assert has_css?(".metric_box h3", text: "Expenses per inhabitant")
      assert has_css?(".metric_box h3", text: "Total expenses")
      assert has_css?(".metric_box h3", text: "Real expenses vs the plan")
      assert has_css?(".metric_box h3", text: "Inhabitants")
      assert has_css?(".metric_box h3", text: "Debt")
      assert page.all(".metric_box .metric").all?{ |e| e.text =~ /\d{2}/}
    end
  end

  def test_main_budget_lines
    with_current_site(site) do
      visit @path

      assert has_content?("Main income and expenses from your council")
      assert has_content?("Income")
      # TODO: this will be translated
      assert has_content?("Impuesto sobre el Valor Añadido")
      assert has_content?("Expenses")
      # TODO: this will be translated
      assert has_content?("Administración General de la Seguridad y Protección Civil")
    end
  end

  def test_highlighted_budget_lines
    with_current_site(site) do
      visit @path

      assert has_content?("Most interesting budget lines")
      assert has_css?("#expense-treemap")
      within(:css, ".explore_slow") do
        # TODO: this will be translated
        assert has_content?("Seguridad y movilidad ciudadana")
        assert has_content?("Otras prestaciones económicas a favor de empleados")
      end
    end
  end
end
