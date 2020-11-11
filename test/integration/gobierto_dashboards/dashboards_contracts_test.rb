# frozen_string_literal: true

require "test_helper"

class GobiertoDashboards::DashboardsContractsTest < ActionDispatch::IntegrationTest
  def setup
    super
    @summary_path = gobierto_dashboards_contracts_summary_path(locale: 'es')
    @contracts_path = gobierto_dashboards_contracts_path

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

  def test_summary
    with(site: site, js: true) do
      visit @summary_path

      ## Active tab is Summary
      assert find(".dashboards-home-nav--tab.is-active").text, 'RESUMEN'

      # Box
      metrics_box = find(".metric_box", match: :first)

      assert metrics_box.has_content?("Licitaciones\n252")
      assert metrics_box.has_content?("licitaciones por importe de\n113.122.855,23 €")

      assert metrics_box.has_content?("Importe medio\n448.900,22 €")
      assert metrics_box.has_content?("Importe mediano\n72.500,00 €")

      assert metrics_box.has_content?("Contratos adjudicados\n223")
      assert metrics_box.has_content?("contratos por importe de\n61.990.830,68 €")

      assert metrics_box.has_content?("Importe medio\n277.985,79 €")
      assert metrics_box.has_content?("Importe mediano\n28.400,00 €")

      ## Headlines
      assert page.has_content?("El 5 % de los contratos son menores de 1.000 €")
      assert page.has_content?("El mayor contrato supone un 20 % de todo el gasto en contratos")
      assert page.has_content?("El 2 % de contratos concentran el 50% de todo el gasto")

      ## Charts
      # Contract type
      contract_type_container = find("#contract-type-bars", match: :first)

      assert contract_type_container.has_content?(/Gestión de servicios públ...\d*1,3 %/)
      assert contract_type_container.has_content?(/Servicios\d*56,5 %/)

      # # Process type
      process_type_container = find("#process-type-bars", match: :first)

      assert process_type_container.has_content?(/Abierto simplificado\d*30,0 %/)
      assert process_type_container.has_content?(/Negociado con publicidad\d*0,4 %/)

      # Assignees table
      first_contract = find(".dashboards-home-main--tr", match: :first)

      assert first_contract.has_content?('LIDER SYSTEM, S.L.')
      assert first_contract.has_content?('40.261,50 €')
    end
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
      assert first_contract.has_content?('Grupo Conforsa Análisis, Desarrollo y Formación , S.A.')

      # Contract
      assert first_contract.has_content?('Prestación del servicio de plataforma de formación online "E...')

      # Amount
      assert first_contract.has_content?('€28,400.00')

      # Date
      assert first_contract.has_content?('2020-07-01')

      # Contracts Show
      ################
      first_contract.click

      # Active tab is still Contracts
      assert find(".dashboards-home-nav--tab.is-active").text, 'CONTRACTS'

      # Url is updated
      assert_equal current_path, "/dashboards/contratos/adjudicaciones/807094"

      # Title
      assert page.has_content?('Prestación del servicio de plataforma de formación online "Escuela Virtual Formalef Getafe".')

      # Assignee
      assert page.has_content?('Grupo Conforsa Análisis, Desarrollo y Formación , S.A.')

      # Contract amount
      assert page.has_content?('€28,400.00')

      # Tender amount
      assert page.has_content?('€40,000.00')

      # Status
      assert page.has_content?('Formalizado')

      # Type
      assert page.has_content?('Abierto simplificado')

      # Assignees Show
      ################
      find("#assignee_show_link").click

      # Url is updated
      assert_equal current_path, "/dashboards/contratos/adjudicatario/0d25ed58b4e09e6985b0d5cf27e7fa98"

      assert page.has_content?("Contracts assigned to")
      assert page.has_content?('Prestación del servicio de plataforma de formación online "Escuela Virtual Formalef Getafe".')

      # We can go back to the contract page
      first_contract = find(".dashboards-home-main--tr", match: :first)
      first_contract.click

      assert_equal current_path, "/dashboards/contratos/adjudicaciones/807094"

    end
  end

end
