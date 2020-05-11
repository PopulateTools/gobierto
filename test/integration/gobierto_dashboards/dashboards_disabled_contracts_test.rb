# frozen_string_literal: true

require "test_helper"

class GobiertoDashboards::DashboardsDisabledContractsTest < ActionDispatch::IntegrationTest
  def setup
    super
    @contracts_path = gobierto_dashboards_contratos_contratos_path
    @tenders_path = gobierto_dashboards_contratos_licitaciones_path

    ::GobiertoModuleSettings.create!({
      site_id: site.id,
      module_name: "GobiertoDashboards",
      settings: settings
    })
  end

  def site
    @site ||= sites(:madrid)
  end

  def settings
    {
      "dashboards_config" => {
        "dashboards" => {
          "contracts" => {
            "enabled" => false,
            "data_urls" => { }
          }
        }
      }
    }
  end

  def test_disability
    with(site: site) do
      visit @contracts_path
      assert_equal 404, page.status_code

      visit @tenders_path
      assert_equal 404, page.status_code
    end
  end

end
