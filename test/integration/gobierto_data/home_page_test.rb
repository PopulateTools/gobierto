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

    def dataset
      @dataset ||= gobierto_data_datasets(:users_dataset)
    end

    def test_home_page
      with_current_site(site) do
        visit @path

        within("div.container", match: :first) do
          assert has_content? "Data"
          assert has_content? dataset.name
        end

        assert_equal @path, current_path
      end
    end

    def test_home_page_with_frontend_disabled
      site.gobierto_data_settings.frontend_disabled = true
      site.gobierto_data_settings.save

      with_current_site(site) do
        visit @path

        within("div.container", match: :first) do
          assert has_no_content? "Data"
          assert has_no_content? dataset.name
        end

        refute_equal @path, current_path
      end
    end
  end
end
