# frozen_string_literal: true

require "test_helper"

class GobiertoPeople::WelcomeControllerTest < GobiertoControllerTest
  def site_with_module_enabled
    @site_with_module_enabled ||= sites(:madrid)
  end

  def site_with_module_disabled
    @site_with_module_disabled ||= sites(:huesca)
  end

  def test_with_module_enabled
    with_current_site(site_with_module_enabled) do
      get gobierto_people_root_path
      assert_response :success
    end
  end

  def test_with_module_disabled
    with_current_site(site_with_module_disabled) do
      get gobierto_people_root_path
      assert_response :redirect
    end
  end
end
