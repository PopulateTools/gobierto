# frozen_string_literal: true

require "test_helper"

class GobiertoVisualizations::VisualizationsSubsidiesTest < ActionDispatch::IntegrationTest
  def setup
    super
    @summary_path = gobierto_visualizations_subsidies_summary_path(locale: 'es')
    @subsidies_path = gobierto_visualizations_subsidies_path

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
    FileUtils.cp File.join(Rails.root, 'test', 'fixtures', 'files', 'gobierto_visualizations', 'subsidies.csv'),
      File.join(Rails.root, 'public', 'subsidies.csv')
  end

  def remove_mock_csv_files
    FileUtils.rm File.join(Rails.root, 'public', 'subsidies.csv')
  end

  def site
    @site ||= sites(:madrid)
  end

  def settings
    {
      "visualizations_config" => {
        "visualizations" => {
          "subsidies" => {
            "enabled" => true,
            "data_urls" => {
              "subsidies" => "/subsidies.csv",
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

      assert metrics_box.has_content?("30\nsubvenciones por importe de\n39.606,19 €")
      assert metrics_box.has_content?("53,33 %\na colectivos por importe de\n38.652,19 €")
      assert metrics_box.has_content?("46,67 %\na particulares por importe de\n954,00 €")

      assert metrics_box.has_content?("Importe medio\n1320,21 €")
      assert metrics_box.has_content?("Importe mediano\n539,58 €")

      ## Headlines
      assert page.has_content?("El 70 % de las subvenciones son menores de 1.000 €")
      assert page.has_content?("La mayor subvención supone un 31.667 % de todo el gasto en subvenciones")
      assert page.has_content?("El 10 % de subvenciones concentran el 50% de todo el gasto")

      ## Charts
      # Category
      category_container = find("#category-bars", match: :first)

      assert category_container.has_content?("URBANISMO")
      assert category_container.has_content?("3,3 %")

      # Beneficiaries table
      first_beneficiary = find(".gobierto-table__tr", match: :first)

      assert first_beneficiary.has_content?('1')
      assert first_beneficiary.has_content?('146,00 €')
    end
  end

  def test_subsidies
    with(site: site, js: true) do
      # Subsidies Index
      #################
      visit @subsidies_path

      assert page.has_content?('BENEFICIARY')
      assert page.has_content?('AMOUNT')
      assert page.has_content?('DATE')

      # Active tab is Subsidies
      assert find(".visualizations-home-nav--tab.is-active").text, 'SUBSIDIES'
      first_subsidy = find(".gobierto-table__tr", match: :first)

      # Beneficiary
      assert first_subsidy.has_content?('1')

      # Amount
      assert first_subsidy.has_content?('€9,500.00')

      # Date
      assert first_subsidy.has_content?('2016-12-01')

      # Subsidies Show
      ################
      first_subsidy.find(".gobierto-table__td", match: :first).find("a.gobierto-table__a").click

      # Active tab is still Subsidies
      assert find(".visualizations-home-nav--tab.is-active").text, 'SUBSIDIES'

      # Url is updated
      assert_equal current_path, "/visualizaciones/subvenciones/subvenciones/2016120195008"

      # Title
      assert page.has_content?('CONCESIÓN DE SUBVENCIONES PARA INSTALACIÓN DE ASCENSORES PARA 2012')

      # Beneficiary
      assert page.has_content?('COMUNIDAD DE PROPIETARIOS C/RUIZ DE ALARNES')
    end
  end

end
