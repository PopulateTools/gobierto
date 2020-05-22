# frozen_string_literal: true

require "test_helper"

class GobiertoDashboards::DashboardsContractsDownloadDataTest < ActionDispatch::IntegrationTest
  def setup
    super
    @summary_path = gobierto_dashboards_summary_path(locale: 'es')
  end

  def site
    @site ||= sites(:madrid)
  end

  def data_download_source
    "http://fake.url/"
  end

  def with_download_data_settings
    {
      "dashboards_config" => {
        "dashboards" => {
          "contracts" => {
            "enabled" => true,
            "data_urls" => {},
            "data_download_source" => data_download_source
          }
        }
      }
    }
  end

  def without_download_data_settings
    {
      "dashboards_config" => {
        "dashboards" => {
          "contracts" => {
            "enabled" => true,
            "data_urls" => {}
          }
        }
      }
    }
  end

  def test_download_data_filled
    ::GobiertoModuleSettings.create!({
      site_id: site.id,
      module_name: "GobiertoDashboards",
      settings: with_download_data_settings
    })

    with(site: site, js: true) do
      visit @summary_path
      assert page.has_content?("Descarga los datos completos")

      link = find(".dashboards-home-aside--download-open-data a", match: :first)
      assert_equal link[:href], data_download_source
    end
  end

  def test_download_data_missing
    ::GobiertoModuleSettings.create!({
      site_id: site.id,
      module_name: "GobiertoDashboards",
      settings: without_download_data_settings
    })

    with(site: site, js: true) do
      visit @summary_path
      refute page.has_content?("Descarga los datos completos")
    end
  end

end
