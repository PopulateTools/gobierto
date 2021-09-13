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

      assert metrics_box.has_content?("Assigned contracts\n219")
      assert metrics_box.has_content?("contracts for a total amount of\n€46,065,307.46")

      assert metrics_box.has_content?("Average amount\n€210,343.87")
      assert metrics_box.has_content?("Median amount\n€27,225.00")

      ## Headlines
      assert page.has_content?("8% of contracts are less than 1.000 €")
      assert page.has_content?("The largest contract means a 27% of all the spending")
      assert page.has_content?("2% of contracts accumulate the 50% of all the spending")

      ## Charts
      # Contract type
      contract_type_container = find("#contract-type-bars", match: :first)
      assert contract_type_container.has_content?(/Supplies\d*42.5/)
      assert contract_type_container.has_content?(/Services\d*47.9/)

      # # Process type
      process_type_container = find("#process-type-bars", match: :first)

      assert process_type_container.has_content?(/Open\d*60.3/)
      assert process_type_container.has_content?(/Open simplified\d*34.7/)

      # Assignees table
      first_assignee = find(".gobierto-table__tr", match: :first)

      assert first_assignee.has_content?('CONTENUR SL')
      assert first_assignee.has_content?('773,050.80')
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
      assert sample_contract.has_content?('SANIVIDA, S.L.')

      # Contract
      assert sample_contract.has_content?('Servicio de ayuda a domicilio')

      # Amount
      assert sample_contract.has_content?('€2,292,724.39')

      # Date
      assert sample_contract.has_content?('4/1/2021')

      # Contracts Show
      ################
      sample_contract = all("tr.gobierto-table__tr")[6]
      sample_contract.click

      # Active tab is still Contracts
      assert find(".visualizations-home-nav--tab.is-active").text, 'CONTRACTS'

      # Url is updated
      assert_equal current_path, "/visualizaciones/contratos/adjudicaciones/38947"

      # Title
      assert page.has_content?('Servicios de monitores deportivos, socorristas acuáticos y sanitarios, en diferentes instalaciones deportivas municipales de Getafe.')

      # Assignee
      assert page.has_content?('EULEN, SA')

      # Contract amount
      assert page.has_content?('€1,647,851.24')

      # Contract amount no taxes
      assert page.has_content?('€1,793,677.20')

      # Status
      assert page.has_content? I18n.t('gobierto_visualizations.visualizations.contract_statuses.formalized')

      # Process type
      assert page.has_content? I18n.t('gobierto_visualizations.visualizations.process_types.open')

      # Assignees Show
      ################
      find("#assignee_show_link").click

      # Url is updated
      assert_equal current_path, "/visualizaciones/contratos/adjudicatario/14137c94986f1d4616e6d17e639a3330"

      assert page.has_content?("Contracts assigned to")
      assert page.has_content?('Servicios de monitores deportivos, socorristas acuáticos y sanitarios, en diferentes instalaciones deportivas municipales de Getafe.')

      # We can go back to the contract page
      first_contract = find(".gobierto-table__tr", match: :first)
      first_contract.click

      assert_equal current_path, "/visualizaciones/contratos/adjudicaciones/38947"
    end
  end

  def test_filters
    with(site: site, js: true) do
      # Contracts Index
      #################
      visit @contracts_path

      assert page.has_content?("2021 (24)")
      assert page.has_content?("2020 (57)")
      assert page.has_content?("2019 (67)")
      assert page.has_content?("2018 (34)")
      assert page.has_content?("2017 (3)")

      table_rows = find_all(".gobierto-table tbody tr")
      assert table_rows.size, 25

      rows_years = table_rows.map{|tr| tr.find_all("td").last.text.split("/").last }.uniq
      assert_equal rows_years, ["2019", "2021", "2020", "2018"]

      # Let's filter by 2021 year
      find("#container-checkbox-dates-2021").click

      assert page.has_content?("2021 (24)")
      assert page.has_no_content?("2020 (57)")
      assert page.has_no_content?("2019 (67)")
      assert page.has_no_content?("2018 (34)")
      assert page.has_no_content?("2017 (3)")

      table_rows = find_all(".gobierto-table tbody tr")
      assert table_rows.size, 24

      rows_years = table_rows.map{|tr| tr.find_all("td").last.text.split("/").last }.uniq
      assert_equal rows_years, ["2021"]
    end
  end

end
