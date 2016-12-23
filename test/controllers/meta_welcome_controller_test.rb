require "test_helper"

class MetaWelcomeControllerTest < GobiertoControllerTest
  def test_index
    get root_path
    assert_redirected_to(gobierto_budgets_site_path)
  end
end
