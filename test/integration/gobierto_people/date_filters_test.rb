# frozen_string_literal: true

require "test_helper"
require "support/gobierto_people/submodules_helper"

module GobiertoPeople
  class DateFiltersTest < ActionDispatch::IntegrationTest
    include ::GobiertoPeople::SubmodulesHelper

    FAR_PAST = 10.years.ago
    RECENT_PAST = 1.day.ago
    NEAR_FUTURE = 1.day.from_now
    FAR_FUTURE = 10.years.from_now

    def setup
      enable_submodule(site, :departments)
      super
    end

    def set_site_dates(site, start_date: nil, end_date: nil)
      config_vars = {}
      config_vars[:gobierto_people_default_filter_start_date] = start_date if start_date
      config_vars[:gobierto_people_default_filter_end_date] = end_date if end_date
      site.configuration.raw_configuration_variables = config_vars.to_json.tr(",", "\n")
      site.save
    end

    def path_without_date_params
      gobierto_people_departments_path
    end

    def path_with_start_date(date)
      gobierto_people_departments_path(start_date: date)
    end

    def path_with_start_and_end_dates(start_date, end_date)
      gobierto_people_departments_path(start_date: start_date, end_date: end_date)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_site_without_default_dates_configured
      with_current_site(site) do
        visit path_without_date_params
        within ".container" do
          assert has_content? "6 registered events"
        end

        visit path_with_start_and_end_dates(RECENT_PAST, NEAR_FUTURE)
        within ".container" do
          assert has_content? "6 registered events"
        end
      end
    end

    def test_site_with_default_dates_configured
      set_site_dates(site, start_date: RECENT_PAST)
      with_current_site(site) do
        visit path_without_date_params
        within ".container" do
          assert has_content? "3 registered events"
        end

        visit path_with_start_date(FAR_PAST)
        within ".container" do
          assert has_content? "6 registered events"
        end

        visit path_with_start_and_end_dates(RECENT_PAST, NEAR_FUTURE)
        within ".container" do
          assert has_content? "0 registered events"
        end
      end
    end

    def test_date_filter_is_not_mantained_without_date_params
      set_site_dates(site, start_date: FAR_PAST)
      with_current_site(site) do
        visit path_without_date_params
        within ".container" do
          assert has_content? "6 registered events"
        end

        visit path_with_start_and_end_dates(RECENT_PAST, FAR_FUTURE)
        within ".container" do
          assert has_content? "3 registered events"
        end

        visit path_without_date_params
        within ".container" do
          assert has_content? "6 registered events"
        end

        visit path_with_start_and_end_dates(RECENT_PAST, NEAR_FUTURE)
        within ".container" do
          assert has_content? "0 registered events"
        end

        visit path_without_date_params
        within ".container" do
          assert has_content? "6 registered events"
        end
      end
    end

    def test_bad_date_params
      set_site_dates(site, start_date: FAR_PAST)
      with_current_site(site) do
        visit path_without_date_params
        within ".container" do
          assert has_content? "6 registered events"
        end

        visit path_with_start_and_end_dates("wadus", "wadus")
        within ".container" do
          assert has_content? "6 registered events"
        end

        visit path_with_start_and_end_dates(RECENT_PAST, "wadus")
        within ".container" do
          assert has_content? "3 registered events"
        end

        visit path_with_start_date("wadus")
        visit path_without_date_params
        within ".container" do
          assert has_content? "6 registered events"
        end
      end
    end
  end
end
