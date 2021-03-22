# frozen_string_literal: true

require "test_helper"

class GobiertoVisualizations::VisualizationsContractsTest < ActionDispatch::IntegrationTest
  def setup
    super
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
      visit @contracts_path

      find("li.visualizations-home-nav--tab", match: :first).click #Click on Summary


      ## Active tab is Summary
      assert find(".visualizations-home-nav--tab.is-active").text, 'SUMMARY'

      # Box
      metrics_box = find(".metric_box", match: :first)

      assert metrics_box.has_content?("Tenders\n250")
      assert metrics_box.has_content?("tenders for a total amount of\n€93,114,128.27")

      assert metrics_box.has_content?("Average amount\n€372,456.51")
      assert metrics_box.has_content?("Median amount\n€72,049.81")

      assert metrics_box.has_content?("Assigned contracts\n25")
      assert metrics_box.has_content?("contracts for a total amount of\n€2,437,973.97")

      assert metrics_box.has_content?("Average amount\n€97,518.96")
      assert metrics_box.has_content?("Median amount\n€8,719.01")

      ## Headlines
      assert page.has_content?("16% of contracts are less than 1.000 €")
      assert page.has_content?("The largest contract means a 41% of all the spending")
      assert page.has_content?("8% of contracts accumulate the 50% of all the spending")

      ## Charts
      # Contract type
      contract_type_container = find("#contract-type-bars", match: :first)

      assert contract_type_container.has_content?(/Supplies\d*60.0/)
      assert contract_type_container.has_content?(/Services\d*40.0/)

      # # Process type
      process_type_container = find("#process-type-bars", match: :first)

      assert process_type_container.has_content?(/Open\d*76.0/)
      assert process_type_container.has_content?(/Open simplified\d*16.0/)

      # Assignees table
      first_assignee = find(".gobierto-table__tr", match: :first)

      assert first_assignee.has_content?('PREVING CONSULTORES S.L.U.')
      assert first_assignee.has_content?('15,100.00')
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

      sample_contract = all("tr.gobierto-table__tr")[4]

      # Assignee
      assert sample_contract.has_content?('Eva Casado Jiménez')

      # Contract
      assert sample_contract.has_content?('Servicios veterinarios del centro de protección de animales')

      # Amount
      assert sample_contract.has_content?('€50,000.00')

      # Date
      assert sample_contract.has_content?('2/15/2020')

      # Contracts Show
      ################
      sample_contract = all("tr.gobierto-table__tr")[6]
      sample_contract.click

      # Active tab is still Contracts
      assert find(".visualizations-home-nav--tab.is-active").text, 'CONTRACTS'

      # Url is updated
      assert_equal current_path, "/visualizaciones/contratos/adjudicaciones/1386359"

      # Title
      assert page.has_content?('Dotación de monitores para el desarrollo del proyecto "Camino escolar seguro".')

      # Assignee
      assert page.has_content?('ASOCIACIÓN TIEMPO LIBRE ALTERNATIVO DEL SUR')

      # Contract amount
      assert page.has_content?('€24,576.66')

      # Contract amount no taxes
      assert page.has_content?('€29,614.00')

      # Status
      assert page.has_content? I18n.t('gobierto_visualizations.visualizations.contract_statuses.awarded')

      # Type
      assert page.has_content? I18n.t('gobierto_visualizations.visualizations.process_types.open_simplified')

      # Assignees Show
      ################
      find("#assignee_show_link").click

      # Url is updated
      assert_equal current_path, "/visualizaciones/contratos/adjudicatario/e1d4a7e1138d5b042a54d4fee5bf7a49"

      assert page.has_content?("Contracts assigned to")
      assert page.has_content?('Dotación de monitores para el desarrollo del proyecto "Camino escolar seguro"')

      # We can go back to the contract page
      first_contract = find(".gobierto-table__tr", match: :first)
      first_contract.click

      assert_equal current_path, "/visualizaciones/contratos/adjudicaciones/1386359"
    end
  end

end
