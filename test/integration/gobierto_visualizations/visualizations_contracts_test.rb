# frozen_string_literal: true

require "test_helper"
require "csv"

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

  # The phase 1 columns are only served by sites already migrated: the rest keep
  # serving the old CSV for an indefinite time, and the viewer must fall back to the
  # previous behaviour there.
  def copy_legacy_csv_files
    strip_csv_columns("contracts.csv", %w[document_number contract_id tender_id contracting_system])
    strip_csv_columns("tenders.csv", %w[contracting_system])
  end

  def strip_csv_columns(file_name, columns)
    path = File.join(Rails.root, "public", file_name)
    rows = CSV.read(path, headers: true)
    headers = rows.headers - columns

    CSV.open(path, "w") do |csv|
      csv << headers
      rows.each { |row| csv << row.values_at(*headers) }
    end
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

      # Url is updated, keyed by contract_id: `id` no longer identifies a contract
      assert_equal current_path, "/visualizaciones/contratos/adjudicaciones/900193"

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

      assert_equal current_path, "/visualizaciones/contratos/adjudicaciones/900193"
    end
  end

  # The fixture groups three contracts (900240, 900241, 900243) under the
  # establishment tender 1410914 through tender_id, with contracting_system 3.
  def test_derived_contracts
    with(site: site, js: true) do
      visit "/visualizaciones/contratos/adjudicaciones/900240"

      # The heading keeps the title of the contract, not the one of the
      # establishment it hangs from: each derived contract names what was actually
      # bought. The expediente is still inherited through tender_id.
      assert_equal "Suministro de un camión con plataforma elevadora telescópica para le servicio de parques y jardines del Ayuntamiento de Getafe",
                   find(".visualizations-contracts-show__title").text
      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.document_number")
      assert page.has_content?("EXP39.2020")

      # And it links to the establishment tender, which has no row of its own in
      # the contracts dataset and is reachable only from here
      establishment_link = find("#establishment_show_link")

      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.establishment")
      assert establishment_link.text.start_with?("EXP39.2020 — Suministro de gasóleo para los vehículos y maquinaria de instalaciones de LYMA")

      # The contracting system is shown as a translated label
      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracting_system")
      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.contracting_systems.based_on_agreement")

      # Its siblings are NOT listed here: they are independent contracts, each with
      # an awardee of its own, and tabling them under "awardees" would read as if
      # this contract had won all three. They belong to the establishment page.
      assert page.has_no_css?("#contracts_show_siblings")
      assert page.has_no_content?("Dotación de monitores para el desarrollo del proyecto")
      assert page.has_no_content?("Ejecución de las obras de adecuación y mejora del centro cívico")

      # What it does show is its single awardee
      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.assignee_description")
      assert page.has_content?("GAM ESPAÑA SERVICIOS DE MAQUINARIA, SLU")

      # And its own amount: it is an independent contract, so the detail must not
      # show the sum of its siblings (€284,396.83)
      assert page.has_content?("€50,000.46")
      assert page.has_no_content?("€284,396.83")
    end
  end

  # The fixture hangs three contracts (900246, 900248, 900249) off the
  # establishment tender 1404032 (EXP35.2020, contracting_system 2), each with its
  # own expediente, and one of them (900249) also carrying a batch_number.
  def test_tender_detail_of_an_establishment
    with(site: site, js: true) do
      visit "/visualizaciones/contratos/adjudicaciones/1404032"

      # The header describes the tender, not whichever derived contract came first
      assert_equal "AM contratación del servicio de consultoría para la búsqueda, apoyo en la presentación, gestión, seguimiento y justificación de ayudas y/o subvenciones convocadas por entes autonómicos, estatales e internacionales, a razón de la mejor relación calidad-precio, con consideración a la calidad del personal adscrito a la ejecución del servicio,así como al menor plazo de tramitación de solicitudes.",
                   find(".visualizations-contracts-show__title").text
      assert page.has_content?("EXP35.2020")
      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.contracting_systems.dynamic_acquisition_establishment")

      # Its status is empty in the fixture, as it is for two of the UJI's tenders:
      # an empty value must stay empty and not become an I18n missing-key message
      assert page.has_no_content?("translation]")

      # Its own estimated value and number of lots
      assert page.has_content?("€500,000.00")
      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.number_of_batches")

      # Nothing that belongs to a contract and not to a tender. The amount column
      # of the table keeps its own heading, so contract_amount is only ruled out
      # where it would describe this page: the total below the table.
      assert page.has_no_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.formalization")
      assert page.has_no_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.assignee_description")
      assert page.has_no_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.question_description")
      assert page.has_no_content? I18n.t("gobierto_visualizations.visualizations.contracts.establishment")

      # The table lists its derived contracts, in derived mode even though one of
      # them carries a batch_number, and the total is labelled as their sum
      derived_table = find("#contracts_show_siblings")

      assert derived_table.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.derived_contract")
      assert derived_table.has_no_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.batch")
      assert_equal 3, derived_table.all("tbody tr").size

      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.derived_contracts_amount")
      assert page.has_content?("€302,934.26")

      # Every row points at a different contract
      row_links = derived_table.all("tbody tr td:first-child a").map { |a| a[:href] }

      assert_equal 3, row_links.uniq.size

      # And each row leads to the detail of its own contract, by contract_id: the
      # three of them share `id`, so they used to be indistinguishable
      within(derived_table) do
        click_link("Servicio de transporte discrecional en autocar con conductor para actividades con finalidad educativa y cultural.", match: :first)
      end

      assert_equal "/visualizaciones/contratos/adjudicaciones/900249", current_path
      assert page.has_content?("€104,051.59")

      # And the page is deterministic: it no longer depends on which derived
      # contract happens to come first in the dataset
      visit "/visualizaciones/contratos/adjudicaciones/1404032"

      assert page.has_content?("EXP35.2020")
      assert page.has_content?("€302,934.26")
      assert_equal 3, find("#contracts_show_siblings").all("tbody tr").size
    end
  end

  def test_derived_contract_with_a_batch_number_keeps_its_own_amount
    with(site: site, js: true) do
      visit "/visualizaciones/contratos/adjudicaciones/900249"

      # It carries batch_number 1, but it is a contract derived from a dynamic
      # acquisition system: its siblings are independent contracts, so its amount
      # is its own and not their sum (€302,934.26)
      assert page.has_content?("€104,051.59")
      assert page.has_no_content?("€302,934.26")
      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.contract_amount")

      # Its own title and its own expediente
      assert_equal "Servicio de transporte discrecional en autocar con conductor para actividades con finalidad educativa y cultural.",
                   find(".visualizations-contracts-show__title").text
      assert page.has_content?("AM/2020/035-03")

      # No table of lots either: the batch_number belongs to its own derived tender,
      # whose sibling lots cannot be told apart because tender_id holds the
      # establishment. Grouping it with the establishment's contracts would list
      # them as if they were its lots.
      assert page.has_no_css?("#contracts_show_siblings")
      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.assignee_description")
      assert page.has_content?("DISCRECIONAL G-18 A.I.E.")

      # And the establishment link leads to the tender page
      find("#establishment_show_link").click

      assert_equal "/visualizaciones/contratos/adjudicaciones/1404032", current_path
      assert page.has_content?("EXP35.2020")
    end
  end

  def test_tender_without_contracts
    with(site: site, js: true) do
      visit "/visualizaciones/contratos/adjudicaciones/1413126"

      assert page.has_content?("CM-01/2021")

      # The tender statuses of the dataset now have a label of their own: this one
      # is provisionally_awarded, which had none until the tender detail showed it
      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.tender_statuses.provisionally_awarded")
      assert page.has_no_content?("translation]")

      assert page.has_no_css?("#contracts_show_siblings")
      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.no_derived_contracts")
    end
  end

  def test_search_by_the_establishment_document_number
    with(site: site, js: true) do
      visit @contracts_path

      # No contract carries EXP35.2020 itself — each has its own expediente — so
      # the search has to reach it through the establishment tender
      find(".gobierto_visualizations-search-container-input").set("EXP35.2020")

      assert page.has_css?(".gobierto-table tbody tr", count: 3)

      titles = find_all(".gobierto-table tbody tr").map { |tr| tr.find_all("td")[1].text }

      assert_equal ["Servicio de intervención psicosocial dirigido a adolescentes en riesgo de violencia y sus familias.",
                    "Servicio de respiro familiar para cuidadores de familiares dependientes o con discapacidad intelectual.",
                    "Servicio de transporte discrecional en autocar con conductor para actividades con finalidad educativa y cultural."],
                   titles.sort
    end
  end

  # The three lots of the tender 43430 are the contracts 900011, 900012 and 900053.
  def test_multi_lot_contract_keeps_adding_up_its_lots
    with(site: site, js: true) do
      visit "/visualizaciones/contratos/adjudicaciones/900053"

      # The header shows the tender title, not the lot-specific one
      assert page.has_content?("Suministro por compra de 650 contenedores de carga lateral")

      # The lots are listed by batch number, and the contract amount is their sum
      lots_table = find("#contracts_show_siblings")

      assert lots_table.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.batch")
      assert_equal ["1", "2", "3"], lots_table.all("tbody tr td:first-child").map(&:text)
      assert page.has_content?("€217,000.00")

      # A lot of an ordinary tender is not a derived contract, so there is no
      # establishment to link to
      assert page.has_no_content? I18n.t("gobierto_visualizations.visualizations.contracts.establishment")
    end
  end

  # The tender page of a multi-lot tender lists each lot as a contract of its own.
  def test_tender_detail_of_a_multi_lot_tender
    with(site: site, js: true) do
      visit "/visualizaciones/contratos/adjudicaciones/43430"

      lots_table = find("#contracts_show_siblings")

      assert lots_table.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.derived_contract")
      assert_equal 3, lots_table.all("tbody tr").size
      assert_equal 3, lots_table.all("tbody tr td:first-child a").map { |a| a[:href] }.uniq.size
      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.derived_contracts_amount")
      assert page.has_content?("€217,000.00")
    end
  end

  def test_minor_contract
    with(site: site, js: true) do
      visit "/visualizaciones/contratos/adjudicaciones/900245"

      # It carries its own expediente, not one joined from the tenders dataset
      assert page.has_content? I18n.t("gobierto_visualizations.visualizations.contracts.document_number")
      assert page.has_content?("CM/2020/042")

      # No tender, so no siblings table and no contracting system row
      assert page.has_no_css?("#contracts_show_siblings")
      assert page.has_no_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracting_system")
      assert page.has_no_content? I18n.t("gobierto_visualizations.visualizations.contracts.establishment")
      assert page.has_content?("€80,776.00")
    end
  end

  def test_contracting_system_filter
    with(site: site, js: true) do
      visit @contracts_path

      # Only the contracting systems present in the data show up as options: none
      # of the establishment ones, which belong to the tenders
      block = find("#filters-contracting-system")

      assert block.has_content?("#{I18n.t('gobierto_visualizations.visualizations.contracting_systems.based_on_agreement')} (3)")
      assert block.has_content?("#{I18n.t('gobierto_visualizations.visualizations.contracting_systems.dynamic_acquisition')} (3)")
      assert block.has_no_content? I18n.t("gobierto_visualizations.visualizations.contracting_systems.based_on_agreement_establishment")

      assert_equal 25, find_all(".gobierto-table tbody tr").size

      # This filter has no dc chart behind it, so the reduction is applied by hand
      within(block) do
        find(".gobierto-filter-checkbox", text: I18n.t("gobierto_visualizations.visualizations.contracting_systems.dynamic_acquisition")).click
      end

      assert page.has_css?(".gobierto-table tbody tr", count: 3)

      assignees = find_all(".gobierto-table tbody tr").map { |tr| tr.find_all("td").first.text }
      assert_equal ["ASOCIACIÓN CENTRO TRAMA", "DISCRECIONAL G-18 A.I.E.", "Ilunion Sociosanitario S.A."], assignees.sort

      # Unchecking it brings the whole dataset back
      within(block) do
        find(".gobierto-filter-checkbox", text: I18n.t("gobierto_visualizations.visualizations.contracting_systems.dynamic_acquisition")).click
      end

      assert page.has_css?(".gobierto-table tbody tr", count: 25)
    end
  end

  def test_legacy_csv_degrades_to_the_previous_behaviour
    copy_legacy_csv_files

    with(site: site, js: true) do
      visit @contracts_path

      # Without the column there is no option, and the sidebar block disappears
      assert page.has_no_css?("#filters-contracting-system")
      assert page.has_content?("2021 (24)")
      assert_equal 25, find_all(".gobierto-table tbody tr").size

      # Multi-lot contracts still group through the id column
      visit "/visualizaciones/contratos/adjudicaciones/43430"

      assert page.has_content?("Suministro por compra de 650 contenedores de carga lateral")
      assert_equal ["1", "2", "3"], find("#contracts_show_siblings").all("tbody tr td:first-child").map(&:text)
      assert page.has_content?("€217,000.00")
      assert page.has_no_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracting_system")

      # The establishment block needs contracting_system to know a contract is
      # derived, so it never shows up here
      assert page.has_no_content? I18n.t("gobierto_visualizations.visualizations.contracts.establishment")

      # And a contract with no siblings shows its assignee, not a table
      visit "/visualizaciones/contratos/adjudicaciones/38947"

      assert page.has_no_css?("#contracts_show_siblings")
      assert page.has_css?("#assignee_show_link")

      # Every row of the table still routes through `id`, so the detail always
      # resolves to a contract and the tender branch is never reached: this is what
      # the sites still serving the old CSV depend on.
      visit @contracts_path

      first_row = find(".gobierto-table tbody tr", match: :first)
      assignee = first_row.find_all("td").first.text
      first_row.click

      assert page.has_css?("#contracts_show_siblings, #assignee_show_link")
      assert page.has_content?(assignee)
      assert page.has_no_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.derived_contracts_amount")
      assert page.has_no_content? I18n.t("gobierto_visualizations.visualizations.contracts.contracts_show.no_derived_contracts")
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
      assert_equal table_rows.size, 25

      rows_years = table_rows.map{|tr| tr.find_all("td").last.text.split("/").last }.uniq
      assert_equal rows_years, ["2019", "2021", "2020", "2018", "Invalid Date"]

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
