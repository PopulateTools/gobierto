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

      first_contract = find(".dashboards-home-main--tr", match: :first)

      # Assignee
      assert first_contract.has_content?('Grupo Conforsa Análisis, Desarrollo y Formación , S.A.')

      # Contractor
      assert first_contract.has_content?('Presidencia del Organismo Autónomo Agencia Local de Empleo y Formación del Ayuntamiento de Getafe')

      # Amount
      assert first_contract.has_content?('34364.0')

      # Date
      assert first_contract.has_content?('2020-09-30')

      # Contracts Show
      ################
      first_contract.click

      # Url is updated
      assert_equal current_path, "/dashboards/contratos/contratos/807094"

      # Title
      assert page.has_content?('Prestación del servicio de plataforma de formación online "Escuela Virtual Formalef Getafe"')

      # Assignee
      assert page.has_content?('Grupo Conforsa Análisis, Desarrollo y Formación , S.A.')

      # Contract amount
      assert page.has_content?('34364.0')

      # Tender amount
      assert page.has_content?('48400.0')

      # Status
      assert page.has_content?('Formalizado')

      # Type
      assert page.has_content?('Abierto simplificado')
    end
  end

  def test_tenders
    with(site: site, js: true) do
      # Tenders Index
      ###############
      visit @tenders_path

      first_tender = find(".dashboards-home-main--tr", match: :first)

      # Contractor
      assert first_tender.has_content?('Presidencia del Organismo Autónomo Agencia Local de Empleo y Formación del Ayuntamiento de Getafe')

      # Status
      assert first_tender.has_content?('Renuncia')

      # Date
      assert first_tender.has_content?('2019-09-24')


      # Tenders Show
      ##############
      first_tender.click

      # Url is updated
      assert_equal current_path, "/dashboards/contratos/licitaciones/435789"

      # Tender amount
      assert page.has_content?('48400.0')

      # Status
      assert page.has_content?('Renuncia')

      # Type
      assert page.has_content?('Abierto simplificado')
    end
  end

end
