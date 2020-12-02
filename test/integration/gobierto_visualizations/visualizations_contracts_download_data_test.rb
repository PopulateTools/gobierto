# frozen_string_literal: true

require "test_helper"

class GobiertoVisualizations::VisualizationsContractsDownloadDataTest < ActionDispatch::IntegrationTest
  def setup
    super
    @summary_path = gobierto_visualizations_contracts_summary_path(locale: 'es')
  end

  def site
    @site ||= sites(:madrid)
  end

  def data_download_source
    "http://fake.url/"
  end

  def with_download_data_settings
    {
      "visualizations_config" => {
        "visualizations" => {
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
      "visualizations_config" => {
        "visualizations" => {
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
      module_name: "GobiertoVisualizations",
      settings: with_download_data_settings
    })

    with(site: site, js: true) do
      visit @summary_path
      assert page.has_content?("Descarga los datos completos")

      link = find(".visualizations-home-aside--download-open-data a", match: :first)
      assert_equal link[:href], data_download_source
    end
  end

  def test_download_data_missing
    ::GobiertoModuleSettings.create!({
      site_id: site.id,
      module_name: "GobiertoVisualizations",
      settings: without_download_data_settings
    })

    with(site: site, js: true) do
      visit @summary_path
      refute page.has_content?("Descarga los datos completos")
    end
  end

end
