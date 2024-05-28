# frozen_string_literal: true

require "test_helper"

module GobiertoIndicators
  class IndicatorShowTest < ActionDispatch::IntegrationTest
    def ita_path
      @ita_path ||= gobierto_indicators_indicators_ita_path(2014)
    end

    def ip_path
      @ip_path ||= gobierto_indicators_indicators_ip_path(2012)
    end

    def gci_path
      @gci_path ||= gobierto_indicators_indicators_gci_path
    end

    def gci_indicator
      @gci_indicator ||= gobierto_indicators_indicators(:gci)
    end

    def gci_years
      @gci_years ||= [2017, 2016, 2015, 2014, 2013, 2012, 2011, 2010, 2009, 2008]
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_indicator_ita
      skip "Disabled indicator"
      with_javascript do
        with_current_site(site) do
          visit ita_path

          assert has_content? "The indicators ITA (Index of Transparency of the City councils)"
          assert has_content? "S'especifiquen dades biogràfiques de l'Alcalde/ssa i dels regidors/ores de l'Ajuntament?"
          within ".item-check" do
            assert page.find("i")["class"].include?("fa-check")
          end
        end
      end
    end

    def test_indicator_ita
      skip "Disabled indicator"
      with_javascript do
        with_current_site(site) do
          visit ip_path

          assert has_content? "Infoparticipa és un projecte desenvolupat per el LPCCP, des de l'any 2012"
          assert has_content? "Es dóna informació bàsica sobre l'Alcalde: nom i cognoms, foto i partit polític?"
          within ".item-check" do
            assert page.find("i")["class"].include?("fa-check")
          end
        end
      end
    end

    def test_indicator_gci
      skip "Disabled indicator"
      with_javascript do
        with_current_site(site) do
          visit gci_path

          assert has_content? "The GCI indicators (Global City Indicators), which
                               reflect The quality of life of the city is defined
                               by the World Bank, association with the purpose of
                               fighting poverty and supporting development. The
                               indicators may vary according to the selected year.".squish

          assert has_content? "2017"

          assert has_content? "S - Serveis de ciutat"
          assert has_content? "Habitatges"
          assert has_content? "Nombre total de llars"
          assert has_content? "16,366"

          within 'li.item.item-lvl-2' do
            find('div[class=item-text]').click
          end

          assert has_content? "Nombre total de llars"
          assert has_content? "El nombre total d'habitatges amb persones empadronades,
                               tant en règim de lloguer com en propietat.".squish
          assert has_content? "16,366"
          assert has_content? "Calculation"
          assert has_content? "Suma total d'habitatges amb persones empadronades"
          assert has_content? "Source"
          assert has_content? "Ajuntament: Padró Municipal d'Habitants"
        end
      end
    end
  end
end
