# frozen_string_literal: true

require "test_helper"

module GobiertoExports
  class HomePageTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_exports_root_path
    end

    def site
      @site ||= sites(:madrid)
    end

    def gp_enabled_submodules
      site.gobierto_people_settings.submodules_enabled
    end

    def test_index
      with_current_site(site) do
        visit @path

        assert has_selector?("h1", text: "Download data")
        assert has_selector?("h2", text: "Officials and Agendas")
        assert has_selector?("h2", text: "Budget lines")
        assert has_selector?("h3", text: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last)
      end
    end

    def test_index_with_javascript
      with_javascript do
        with_current_site(site) do
          visit @path

          assert has_selector?("h1", text: "Download data")
          assert has_selector?("h2", text: "Officials and Agendas")
          assert has_selector?("h2", text: "Budget lines")
          assert has_selector?("h3", text: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last)
        end
      end
    end

    def test_index_hides_disabled_submodules
      gp_enabled_submodules.delete("statements")

      with_current_site(site) do
        visit @path

        assert has_selector?("h3", text: "Agendas")
        assert has_no_selector?("h3", text: "Statements")
      end
    end

    def test_index_without_any_submodules
      %w(officials agendas blogs statements departments).each do |submodule|
        gp_enabled_submodules.delete(submodule)
      end

      with_current_site(site) do
        visit @path
        assert has_content? "There aren't any active submodules"
      end
    end
  end
end
