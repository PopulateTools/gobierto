require "test_helper"

class MetaWelcomeControllerTest < GobiertoControllerTest
  def test_index_without_site_directs_to_404
    get root_path
    assert_response :missing
  end
end
