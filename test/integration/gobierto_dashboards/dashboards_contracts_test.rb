# frozen_string_literal: true

require "test_helper"

class GobiertoDashboards::DashboardsContractsTest < ActionDispatch::IntegrationTest
  def setup
    super
    @contracts_path = gobierto_dashboards_contratos_contratos_path
    @tenders_path = gobierto_dashboards_contratos_licitaciones_path

    ::GobiertoModuleSettings.create!({
      site_id: site.id,
      module_name: "GobiertoDashboards",
      settings: settings
    })

    copy_mock_csv_files
  end

  def teardown
    remove_mock_csv_files
  end

  def copy_mock_csv_files
    FileUtils.cp File.join(Rails.root, 'test', 'fixtures', 'files', 'gobierto_dashboards', 'contracts.csv'),
      File.join(Rails.root, 'public', 'contracts.csv')

    FileUtils.cp File.join(Rails.root, 'test', 'fixtures', 'files', 'gobierto_dashboards', 'tenders.csv'),
      File.join(Rails.root, 'public', 'tenders.csv')
  end

  def remove_mock_csv_files
    FileUtils.rm File.join(Rails.root, 'public', 'contracts.csv')
    FileUtils.rm File.join(Rails.root, 'public', 'tenders.csv')
  end

  def site
    @site ||= sites(:madrid)
  end

  def settings
    {
      "dashboards_config" => {
        "dashboards" => {
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

  def test_contracts
    with(site: site, js: true) do
      # Contracts Index
      #################
      visit @contracts_path

      assert page.has_content?('ASSIGNEE')
      assert page.has_content?('CONTRACTOR')
      assert page.has_content?('AMOUNT')

      # Active tab is Contracts
      assert find(".dashboards-home-nav--tab.is-active").text, 'CONTRACTS'

      first_contract = find(".dashboards-home-main--tr", match: :first)

      # Assignee
      assert first_contract.has_content?('IMPORTACIONES INDUSTRIALES, S.A.')

      # Contractor
      assert first_contract.has_content?('Consejero Delegado del Consejo de Administración de Limpieza y Medio Ambiente de Getafe')

      # Amount
      assert first_contract.has_content?('€28,600.53')

      # Date
      assert first_contract.has_content?('2017-04-18')

      # Contracts Show
      ################
      first_contract.click

      # Active tab is still Contracts
      assert find(".dashboards-home-nav--tab.is-active").text, 'CONTRACTS'

      # Url is updated
      assert_equal current_path, "/dashboards/contratos/contratos/56111"

      # Title
      assert page.has_content?('Suministro, de forma sucesiva y por precio unitario, y por lotes de equipos de protección individual para el personal de Limpieza y Medio Ambiente de Getafe SAM')

      # Assignee
      assert page.has_content?('IMPORTACIONES INDUSTRIALES, S.A.')

      # Contract amount
      assert page.has_content?('€28,600.53')

      # Tender amount
      assert page.has_content?('€123,015.86')

      # Status
      assert page.has_content?('Desierto')

      # Type
      assert page.has_content?('Abierto')
    end
  end

  def test_tenders
    with(site: site, js: true) do
      # Tenders Index
      ###############
      visit @tenders_path

      # Active tab is Tenders
      assert find(".dashboards-home-nav--tab.is-active").text, 'TENDERS'

      first_tender = find(".dashboards-home-main--tr", match: :first)

      # Contractor
      assert first_tender.has_content?('Consejero Delegado del Consejo de Administración de Limpieza y Medio Ambiente de Getafe, Sociedad Anónima Municipal')

      # Status
      assert first_tender.has_content?('Adjudicado provisionalmente')

      # Date
      assert first_tender.has_content?('2014-03-24')


      # Tenders Show
      ##############
      first_tender.click

      # Active tab is still Tenders
      assert find(".dashboards-home-nav--tab.is-active").text, 'TENDERS'

      # Url is updated
      assert_equal current_path, "/dashboards/contratos/licitaciones/174387"

      # Title
      assert page.has_content?('suministro mediante sistema de renting de tres camiones contenedores de carga trasera')

      # Tender amount
      assert page.has_content?('€604,000.00')

      # Status
      assert page.has_content?('Adjudicado provisionalmente')

      # Type
      assert page.has_content?('Abierto')
    end
  end

end
