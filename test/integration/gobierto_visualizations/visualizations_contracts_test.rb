# frozen_string_literal: true

require "test_helper"

class GobiertoVisualizations::VisualizationsContractsTest < ActionDispatch::IntegrationTest
  def setup
    super
    @summary_path = gobierto_visualizations_contracts_summary_path(locale: 'es')
    @contracts_path = gobierto_visualizations_contracts_path

    ::GobiertoModuleSettings.create!({
      site_id: site.id,
      module_name: "GobiertoVisualizations",
      settings: settings
    })

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

  def settings
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

  def test_summary
    with(site: site, js: true) do
      visit @summary_path

      ## Active tab is Summary
      assert find(".visualizations-home-nav--tab.is-active").text, 'RESUMEN'

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
      first_contract = find(".gobierto-table__tr", match: :first)

      assert first_contract.has_content?('LIDER SYSTEM')
      assert first_contract.has_content?('40.261,50 €')
    end
  end

  def test_contracts
    with(site: site, js: true) do
      # Contracts Index
      #################
      visit @contracts_path

      assert page.has_content?('ASSIGNEE')
      assert page.has_content?('CONTRACT')
      assert page.has_content?('AMOUNT')

      # Active tab is Contracts
      assert find(".visualizations-home-nav--tab.is-active").text, 'CONTRACTS'

      first_contract = find(".gobierto-table__tr", match: :first)

      # Assignee
      assert first_contract.has_content?('UTE ABALA - FACTO -ORTHEM')

      # Contract
      assert first_contract.has_content?('Construcción de dos edificios de viviendas con protección púb')

      # Amount
      assert first_contract.has_content?('€12,207,444.40')

      # Date
      assert first_contract.has_content?('12/16/2019')

      # Contracts Show
      ################
      first_contract.click

      # Active tab is still Contracts
      assert find(".visualizations-home-nav--tab.is-active").text, 'CONTRACTS'

      # Url is updated
      assert_equal current_path, "/visualizaciones/contratos/adjudicaciones/260522"

      # Title
      assert page.has_content?('Construcción de dos edificios de viviendas con protección pública, garajes y trasteros de consumo energético casi nulo.')

      # Assignee
      assert page.has_content?('UTE ABALA - FACTO -ORTHEM')

      # Contract amount
      assert page.has_content?('€12,459,118.59')

      # Contract amount no taxes
      assert page.has_content?('€12,207,444.40')

      # Status
      assert page.has_content? I18n.t('gobierto_visualizations.visualizations.status_types.formalized')

      # Type
      assert page.has_content? I18n.t('gobierto_visualizations.visualizations.process_type.open')

      # Assignees Show
      ################
      find("#assignee_show_link").click

      # Url is updated
      assert_equal current_path, "/visualizaciones/contratos/adjudicatario/cd0db88d9c0da8d17bc82cbad2b3a235"

      assert page.has_content?("Contracts assigned to")
      assert page.has_content?('Construcción de dos edificios de viviendas con protección pública, garajes y trasteros de consumo energético casi nulo.')

      # We can go back to the contract page
      first_contract = find(".gobierto-table__tr", match: :first)
      first_contract.click

      assert_equal current_path, "/visualizaciones/contratos/adjudicaciones/260522"

    end
  end

end
