# frozen_string_literal: true

require "test_helper"

class GobiertoVisualizations::VisualizationsContractsDownloadDataTest < ActionDispatch::IntegrationTest
  def setup
    super
    @summary_path = gobierto_visualizations_contracts_summary_path
    copy_mock_csv_files
  end

  def teardown
    remove_mock_csv_files
  end

  def copy_mock_csv_files
    FileUtils.cp File.join(Rails.root, 'test', 'fixtures', 'files', 'gobierto_visualizations', 'contracts.csv'),
      File.join(Rails.root, 'public', 'contracts.csv')

    FileUtils.cp File.join(Rails.root, 'test', 'fixtures', 'files', 'gobierto_visualizations', 'tenders.csv'),
      File.join(Rails.root, 'public', 'tenders.csv')
  end

  def remove_mock_csv_files
    FileUtils.rm File.join(Rails.root, 'public', 'contracts.csv')
    FileUtils.rm File.join(Rails.root, 'public', 'tenders.csv')
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
            "data_urls" => {
              "tenders" => "/tenders.csv",
              "contracts" => "/contracts.csv"
            },
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
            "data_urls" => {
              "tenders" => "/tenders.csv",
              "contracts" => "/contracts.csv"
            }
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
      assert page.has_content?("Download the full dataset in a reusable format")

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
      assert page.has_no_content?("Download the full dataset in a reusable format")
    end
  end

end
