# frozen_string_literal: true

require "test_helper"

module GobiertoData
  class HomePageTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_data_root_path
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_home_page
      with_current_site(site) do
        visit @path

        within("nav.main-nav") do
          assert has_content? "Data"
        end

        assert_equal @path, current_path
      end
    end

    def test_home_page_with_frontend_disabled
      site.gobierto_data_settings.frontend_disabled = true
      site.gobierto_data_settings.save

      with_current_site(site) do
        visit @path

        within("nav.main-nav") do
          assert has_no_content? "Data"
        end

        refute_equal @path, current_path
      end
    end
  end
end
