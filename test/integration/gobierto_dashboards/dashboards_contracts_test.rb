# frozen_string_literal: true

require "test_helper"

class GobiertoDashboards::DashboardsContractsTest < ActionDispatch::IntegrationTest
  def setup
    super
    @summary_path = gobierto_dashboards_contracts_path(locale: 'es')
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

  def test_summary
    with(site: site, js: true) do
      visit @summary_path

      ## Active tab is Summary
      assert find(".dashboards-home-nav--tab.is-active").text, 'RESUMEN'

      # Box
      metrics_box = find(".metric_box", match: :first)

      assert metrics_box.has_content?("Licitaciones\n252")
      assert metrics_box.has_content?("licitaciones por importe de\n134.068.916,04 €")
      assert metrics_box.has_content?("Importe medio\n532.019,51 €")

      assert metrics_box.has_content?("Importe medio\n532.019,51 €")
      assert metrics_box.has_content?("Importe mediano\n87.725,00 €")

      assert metrics_box.has_content?("Contratos adjudicados\n223")
      assert metrics_box.has_content?("contratos por importe de\n72.894.648,94 €")

      assert metrics_box.has_content?("Importe medio\n326.881,83 €")
      assert metrics_box.has_content?("Importe mediano\n33.668,25 €")

      assert metrics_box.has_content?("Ahorro medio de licitación a adjudicación\n44,44 %")

      ## Headlines
      assert page.has_content?("El 5 % de los contratos son menores de 1.000 €")
      assert page.has_content?("El mayor contrato supone un 18 % de todo el gasto en contratos")
      assert page.has_content?("El 2 % de contratos concentran el 50% de todo el gasto")


      ## Charts
      # Contract type
      contract_type_container = find("#contract-type-bars", match: :first)

      assert contract_type_container.has_content?(/Gestión de servicios públicos\d*1,3 %/)
      assert contract_type_container.has_content?(/Servicios\d*56,5 %/)

      # # Process type
      process_type_container = find("#process-type-bars", match: :first)

      assert process_type_container.has_content?(/Abierto simplificado\d*30,0 %/)
      assert process_type_container.has_content?(/Negociado con publicidad\d*0,4 %/)

      # Assignees table
      first_contract = find("#assignees-table-body tr", match: :first)

      assert first_contract.has_content?('CONTENUR, S.L.')
      assert first_contract.has_content?(' 4 ')
      assert first_contract.has_content?('412.324,00 €')
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
      assert first_contract.has_content?('Marc Gil Van Beveren')

      # Contract
      assert first_contract.has_content?('Servicios de asesoramiento jurídico, defensa y formación en ...')

      # Amount
      assert first_contract.has_content?('€5,808.00')

      # Date
      assert first_contract.has_content?('2055-12-31')

      # Contracts Show
      ################
      first_contract.click

      # Active tab is still Contracts
      assert find(".dashboards-home-nav--tab.is-active").text, 'CONTRACTS'

      # Url is updated
      assert_equal current_path, "/dashboards/contratos/contratos/807008"

      # Title
      assert page.has_content?('Servicios de asesoramiento jurídico, defensa y formación en materia de contratación pública')

      # Assignee
      assert page.has_content?('Marc Gil Van Beveren')

      # Contract amount
      assert page.has_content?('€5,808.00')

      # Tender amount
      assert page.has_content?('€217,800.00')

      # Status
      assert page.has_content?('Formalizado')

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
      assert first_tender.has_content?('2020-05-13')


      # Tenders Show
      ##############
      first_tender.click

      # Active tab is still Tenders
      assert find(".dashboards-home-nav--tab.is-active").text, 'TENDERS'

      # Url is updated
      assert_equal current_path, "/dashboards/contratos/licitaciones/990198"

      # Title
      assert page.has_content?('Servicio de formación para renovación del Certificado de Aptitud Profesional .')

      # Tender amount
      assert page.has_content?('€33,600.00')

      # Status
      assert page.has_content?('Adjudicado provisionalmente')

      # Type
      assert page.has_content?('Abierto simplificado')
    end
  end

end
