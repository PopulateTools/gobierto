# frozen_string_literal: true

require "test_helper"

module GobiertoCitizensCharters
  class HomePageTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_citizens_charters_root_path
    end

    def site
      @site ||= sites(:madrid)
    end

    def services
      @services ||= site.services
    end

    def charters
      @charters ||= site.charters
    end

    def last_edition
      @last_edition ||= gobierto_citizens_charters_editions(:devices_operation_2018)
    end

    def editions_of_last_period
      @editions_of_last_period ||= site.editions.of_same_period(last_edition).select { |edition| edition.commitment.active? }
    end

    def test_home_page_with_display_categories_setting_disabled
      site.settings_for_module("GobiertoCitizensCharters").enable_services_home = false
      site.settings_for_module("GobiertoCitizensCharters").save

      proportions = editions_of_last_period.map(&:proportion).compact
      percentage = proportions.sum / proportions.count

      with_current_site(site) do
        visit @path

        assert has_content?("Global compliance")
        assert has_css?(".charters-box-container")

        within "div.charters-box--lead div.results-value" do
          assert has_content? "#{ percentage.round(1) }%"
        end

        charters.each do |charter|
          within "#charter-#{ charter.id }" do
            assert has_content? charter.title
          end
        end
      end
    end

    def test_home_page_with_display_categories_setting_enabled
      site.settings_for_module("GobiertoCitizensCharters").enable_services_home = true
      site.settings_for_module("GobiertoCitizensCharters").save

      with_current_site(site) do
        visit @path
        assert has_content?("Services")
        services.each do |service|
          assert has_content? service.title
        end

        charters.each do |charter|
          assert has_no_content? charter.title
        end
      end
    end

    def test_home_page_with_display_categories_setting_enabled_and_services_disabled
      site.settings_for_module("GobiertoCitizensCharters").enable_services_home = true
      site.settings_for_module("GobiertoCitizensCharters").disable_services = true
      site.settings_for_module("GobiertoCitizensCharters").save

      with_current_site(site) do
        visit @path
        assert has_content?("Services")
        services.each do |service|
          assert has_content? service.title
        end

        charters.each do |charter|
          assert has_no_content? charter.title
        end
      end
    end
  end
end
