# frozen_string_literal: true

require "test_helper"

module GobiertoCitizensCharters
  class ShowCharterTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_citizens_charters_charter_path(slug: charter.slug)
    end

    def site
      @site ||= sites(:madrid)
    end

    def charter
      @charter ||= gobierto_citizens_charters_charters(:day_care_service_charter)
    end

    def edition_with_large_values
      @edition_with_large_values ||= gobierto_citizens_charters_editions(:equipment_maintenance_2018)
    end
    alias edition_without_other_editions edition_with_large_values

    def edition_with_decimal_values
      @edition_with_decimal_values ||= gobierto_citizens_charters_editions(:families_activities_2018)
    end

    def edition_with_percentage_and_compatible_values
      @edition_with_percentage_and_compatible_values ||= gobierto_citizens_charters_editions(:identification_card_2018)
    end

    def edition_with_percentage_and_not_compatible_values
      @edition_with_percentage_and_not_compatible_values ||= gobierto_citizens_charters_editions(:adequate_menus_2018)
    end
    alias edition_with_other_editions edition_with_percentage_and_not_compatible_values

    def edition_with_decimal_percentage
      @edition_with_decimal_percentage ||= gobierto_citizens_charters_editions(:average_response_time_2018)
    end

    def edition_with_integer_percentage
      @edition_with_integer_percentage ||= gobierto_citizens_charters_editions(:published_service_schedule_2018)
    end

    def edition_with_draft_commitment
      @edition_with_draft_commitment ||= gobierto_citizens_charters_editions(:draft_service_schedule_2018)
    end

    def visible_latest_period_editions
      [edition_with_large_values,
       edition_with_decimal_values,
       edition_with_percentage_and_compatible_values,
       edition_with_percentage_and_not_compatible_values,
       edition_with_integer_percentage,
       edition_with_decimal_percentage]
    end

    def edition_of_old_period
      @edition_of_old_period ||= gobierto_citizens_charters_editions(:old_service_schedule_2010)
    end

    def test_show_last_edition
      with_current_site(site) do
        visit @path
        within "div.dropdown div.dropdown-inner", match: :first do
          assert has_content? "Data corresponding to #{ visible_latest_period_editions.first.front_period_params[:period] }"
        end
        visible_latest_period_editions.each do |edition|
          within "div.charter", text: edition.commitment.description do
            assert has_content? edition.commitment.title
          end
        end

        refute has_content? edition_of_old_period.commitment.description
        refute has_content? edition_with_draft_commitment.commitment.description
      end
    end

    def test_change_edition
      old_period_year = edition_of_old_period.front_period_params[:period]
      with_current_site(site) do
        visit @path
        click_link "Data corresponding to #{ old_period_year }"
        within "div.dropdown div.dropdown-inner", match: :first do
          assert has_content? "Data corresponding to #{ old_period_year }"
        end
        assert has_content? edition_of_old_period.commitment.description
        visible_latest_period_editions.each do |edition|
          refute has_content? edition.commitment.description
        end
      end
    end

    def test_sparkline_presence
      with_current_site(site) do
        with_javascript do
          visit @path
          within "#sparkline-#{ edition_without_other_editions.id }" do
            refute has_css? "svg"
          end

          within "#sparkline-#{ edition_with_other_editions.id }" do
            assert has_css? "svg"
          end
        end
      end
    end

    def test_global_progress
      proportion = visible_latest_period_editions.map(&:proportion).compact
      global_progress = proportion.sum / proportion.count
      with_current_site(site) do
        visit @path
        within "div.charter-subheader", text: "We fulfill the commitments of this charter to" do
          assert has_content? "#{ global_progress.round(1) }%"
        end
      end
    end

    def test_progress_with_large_values
      with_current_site(site) do
        visit @path
        within "div.charter", text: edition_with_large_values.commitment.description do
          assert has_content? "Reached: 0.5 M"
          assert has_content? "Goal: 1.2 M"
        end

        edition_with_large_values.update_attribute(:max_value, 500_000)
        visit @path
        within "div.charter", text: edition_with_large_values.commitment.description do
          assert has_content? "Reached: 500,000"
          assert has_content? "Goal: 500,000"
        end
      end
    end

    def test_progress_with_decimal_values
      with_current_site(site) do
        visit @path
        within "div.charter", text: edition_with_decimal_values.commitment.description do
          assert has_content? "Reached: 76.7"
          assert has_content? "Goal: 90"
        end
      end
    end

    def test_progress_with_percentage_and_compatible_values
      with_current_site(site) do
        visit @path
        within "div.charter", text: edition_with_percentage_and_compatible_values.commitment.description do
          within "div.charter-number" do
            assert has_content? "33.3%"
          end
          assert has_content? "Reached: 99.9"
          assert has_content? "Goal: 300"
        end
      end
    end

    def test_progress_with_percentage_and_not_compatible_values
      with_current_site(site) do
        visit @path
        within "div.charter", text: edition_with_percentage_and_not_compatible_values.commitment.description do
          within "div.charter-number" do
            assert has_content? "66.7%"
          end
          refute has_content? "Reached"
          refute has_content? "Goal"
        end
      end
    end

    def test_progress_with_decimal_percentage_round
      with_current_site(site) do
        visit @path
        within "div.charter", text: edition_with_decimal_percentage.commitment.description do
          within "div.charter-number" do
            assert has_content? "66.7%"
          end
          refute has_content? "Reached"
          refute has_content? "Goal"
        end
      end
    end

    def test_progress_with_integer_percentage
      with_current_site(site) do
        visit @path
        within "div.charter", text: edition_with_integer_percentage.commitment.description do
          within "div.charter-number" do
            assert has_content? "100%"
          end
          refute has_content? "Reached"
          refute has_content? "Goal"
        end
      end
    end
  end
end
