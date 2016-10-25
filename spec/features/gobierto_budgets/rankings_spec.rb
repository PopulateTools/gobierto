require 'rails_helper'

RSpec.feature "Rankings", type: :feature do
  before do
    switch_to_subdomain 'presupuestos'
  end

  context 'Population' do

    ranking_url = "/ranking/2012/population"

    scenario 'without specifying a given Place, Madrid is first' do
      visit ranking_url
      expect(page).to have_selector('tr:first', text: 'Madrid')
    end

    scenario 'specifying a given Place, it redirects to the page where that Place appears in the ranking' do
      visit "#{ranking_url}?ine_code=28026"

      expect(page).to have_current_path("#{ranking_url}?ine_code=28026&page=31")
    end

    scenario 'specifying a given Place, the place is highlighted' do
      visit "#{ranking_url}?ine_code=28026"
      expect(page).to have_css('tr#place_28026.selected')
    end

    scenario 'with mixed filters' do
      params = {
        ine_code: 28026,
        f: {
          aarr: 13,
          population:     { from: 10_000, to: 25_000},
          total:          { from: 10_000_000, to: 25_000_000},
          per_inhabitant: { from: 1_000, to: 1_500}
        }
      }

      visit "#{ranking_url}?#{params.to_query}"
      expect(page).to have_selector('tr:nth-child(6) td', :text => 'Brunete')
    end

    scenario 'with excluding filters' do
      params = {
        ine_code: 28026,
        f: {
          aarr: 13,
          population:     { from: 0, to: 5_000}
        }
      }

      visit "#{ranking_url}?#{params.to_query}"
      expect(page).to_not have_selector('td', :text => 'Brunete')
    end
  end

  context 'Total Budget' do
    context 'Expenditure' do

      ranking_url = '/ranking/2012/G/functional/amount'

      scenario 'without specifying a given Place, Madrid is first' do
        visit ranking_url
        expect(page).to have_selector('tr:first', text: 'Madrid')
      end

      scenario 'specifying a given Place, it redirects to the page where that Place appears in the ranking' do
        visit "#{ranking_url}?ine_code=28026"
        expect(page).to have_current_path("#{ranking_url}?ine_code=28026&page=25")
      end

      scenario 'specifying a given Place, the place is highlighted' do
        visit "#{ranking_url}?ine_code=28026"
        expect(page).to have_css('tr#place_28026.selected')
      end

      scenario 'with mixed filters' do
        params = {
          ine_code: 28026,
          f: {
            aarr: 13,
            population:     { from: 5_000, to: 500_000},
            total:          { from: 2_500_000, to: 25_000_000},
            per_inhabitant: { from: 900, to: 1_500}
          }
        }

        visit "#{ranking_url}?#{params.to_query}"
        expect(page).to have_selector('tr:nth-child(12) td', :text => 'Brunete')
      end

      scenario 'with excluding filters' do
        params = {
          ine_code: 28026,
          f: {
            aarr: 13,
            total:          { from: 0, to: 10_000_000}
          }
        }

        visit "#{ranking_url}?#{params.to_query}"
        expect(page).to_not have_selector('tr td', :text => 'Brunete')
      end
    end

    context 'Income' do
      ranking_url = '/ranking/2012/I/economic/amount'

      scenario 'without specifying a given Place, Madrid is first' do
        visit ranking_url
        expect(page).to have_selector('tr:first', text: 'Madrid')
      end

      scenario 'specifying a given Place, it redirects to the page where that Place appears in the ranking' do
        visit "#{ranking_url}?ine_code=28026"
        expect(page).to have_current_path("#{ranking_url}?ine_code=28026&page=19")
      end

      scenario 'specifying a given Place, the place is highlighted' do
        visit "#{ranking_url}?ine_code=28026"
        expect(page).to have_css('tr#place_28026.selected')
      end

      scenario 'with mixed filters' do
        params = {
          ine_code: 28026,
          f: {
            aarr: 13,
            population:     { from: 5_000, to: 500_000},
            total:          { from: 2_500_000, to: 25_000_000}
          }
        }

        visit "#{ranking_url}?#{params.to_query}"
        expect(page).to have_selector('tr:nth-child(10) td', :text => 'Brunete')
      end
    end

  end

  context 'Per Inhabitant Budget' do
    context 'Expenditure' do

      ranking_url = '/ranking/2012/G/economic/amount_per_inhabitant'

      scenario 'without specifying a given Place, Segura de los Baños is first' do
        visit ranking_url
        expect(page).to have_selector('tr:first', text: 'Segura de los Baños')
      end

      scenario 'specifying a given Place, it redirects to the page where that Place appears in the ranking' do
        visit "#{ranking_url}?ine_code=28026"
        expect(page).to have_current_path("#{ranking_url}?ine_code=28026&page=124")
      end

      scenario 'specifying a given Place, the place is highlighted' do
        visit "#{ranking_url}?ine_code=28026"
        expect(page).to have_css('tr#place_28026.selected')
      end

      scenario 'with mixed filters' do
        params = {
          ine_code: 28026,
          f: {
            aarr: 13,
            population:     { from: 5_000, to: 500_000},
            total:          { from: 2_500_000, to: 25_000_000},
            per_inhabitant: { from: 900, to: 1_500}
          }
        }

        visit "#{ranking_url}?#{params.to_query}"
        expect(page).to have_selector('tr:nth-child(5) td', :text => 'Brunete')
      end
    end

    context 'Expenditure => Specific Budget Lines' do

      ranking_url = '/ranking/2012/G/economic/amount_per_inhabitant/61'

      scenario 'without specifying a given Place, Jalón de Cameros is first' do
        visit ranking_url
        expect(page).to have_selector('tr:first', text: 'Jalón de Cameros')
      end

      scenario 'specifying a given Place, it redirects to the page where that Place appears in the ranking' do
        visit "#{ranking_url}?ine_code=28026"
        expect(page).to have_current_path("#{ranking_url}?ine_code=28026&page=128")
      end

      scenario 'specifying a given Place, the place is highlighted' do
        visit "#{ranking_url}?ine_code=28026"
        expect(page).to have_css('tr#place_28026.selected')
      end

      scenario 'with autonomous region filters' do
        params = {
          ine_code: 28026,
          f: {
            aarr: 13
          }
        }

        visit "#{ranking_url}?#{params.to_query}"
        expect(page).to have_selector('tr:nth-child(7) td', :text => 'Brunete')
      end

      scenario 'with population filters' do
        params = {
          ine_code: 28026,
          f: {
            population:     { from: 5_000, to: 500_000}
          }
        }

        visit "#{ranking_url}?#{params.to_query}"
        expect(page).to have_selector('tr:nth-child(15) td', :text => 'Brunete')
      end

      scenario 'with total_budget filters' do
        params = {
          ine_code: 28026,
          f: {
            total: { from: 100_000, to: 200_000 }
          }
        }

        visit "#{ranking_url}?#{params.to_query}"
        expect(page).to have_selector('tr:nth-child(14) td', :text => 'Brunete')
      end

      scenario 'with per_inhabitant filters' do
        params = {
          ine_code: 28026,
          f: {
            per_inhabitant: { from: 0, to: 500}
          }
        }

        visit "#{ranking_url}?#{params.to_query}"
        expect(page).to have_selector('tr:nth-child(16) td', :text => 'Brunete')
      end

      scenario 'with mixed filters' do
        params = {
          ine_code: 28026,
          f: {
            aarr: 13,
            population:     { from: 1_000, to: 25_000},
            total:          { from: 100_000, to: 200_000},
            per_inhabitant: { from: 0, to: 500}
          }
        }

        visit "#{ranking_url}?#{params.to_query}"
        expect(page).to have_selector('tr:nth-child(9) td', :text => 'Brunete')
      end

      scenario 'with filters that exclude selected ine_code' do
        params = {
          ine_code: 28026,
          f: {
            aarr: 13,
            per_inhabitant: { from: 500, to: 1000}
          }
        }

        visit "#{ranking_url}?#{params.to_query}"
        expect(page).to_not have_selector('tr td', :text => 'Brunete')
      end

      scenario 'shows (and filters by) the values of the budget line, not the total values for the place' do

        bl_ranking_url = "/ranking/2015/G/functional/amount_per_inhabitant/162?ine_code=28079"

        visit bl_ranking_url

        expect(page).to have_selector('tr.selected td.location', :text => 'Madrid')
        expect(page).to have_selector('tr.selected td.expense_per', :text => '76,11 €')
        expect(page).to have_selector(".filters[data-ranking-url='#{bl_ranking_url}']")

        params = {
          f: {
            aarr: 13
          }
        }

        visit "#{bl_ranking_url}&#{params.to_query}"

        expect(page).to have_selector('tr.selected td.location', :text => 'Madrid')
        expect(page).to have_selector('tr.selected td.expense_per', :text => '76,11 €')
        expect(page).to have_selector(".filters[data-ranking-url='#{bl_ranking_url}']")
      end

    end

    context 'Expenditure => Specific Budget Lines. Ensuring no repetitions' do

      ranking_url = '/ranking/2015/G/economic/amount_per_inhabitant/2'

      scenario 'there should be no repetitions' do
        visit ranking_url
        expect(page).to have_css('#place_9184', maximum: 1)
      end

      scenario 'should show correct values' do
        visit ranking_url
        expect(page).to have_css('#place_9184 .expense_per', text: '5.720 €')
      end

      scenario 'specifying a given Place, it redirects to the page where that Place appears in the ranking' do
        visit "#{ranking_url}?ine_code=43143"
        expect(page).to have_current_path("#{ranking_url}?ine_code=43143&page=2")
      end

    end

    context 'Income' do
      ranking_url = '/ranking/2012/I/economic/amount_per_inhabitant'

      scenario 'without specifying a given Place, Segura de los Baños is first' do
        visit ranking_url
        expect(page).to have_selector('tr:first', text: 'Segura de los Baños')
      end

      scenario 'specifying a given Place, it redirects to the page where that Place appears in the ranking' do
        visit "#{ranking_url}?ine_code=28026"
        expect(page).to have_current_path("#{ranking_url}?ine_code=28026&page=67")
      end

      scenario 'specifying a given Place, the place is highlighted' do
        visit "#{ranking_url}?ine_code=28026"
        expect(page).to have_css('tr#place_28026.selected')
      end

      scenario 'with mixed filters' do
        params = {
          ine_code: 28026,
          f: {
            aarr: 13,
            population:     { from: 5_000, to: 500_000},
            total:          { from: 2_500_000, to: 25_000_000}
          }
        }

        visit "#{ranking_url}?#{params.to_query}"
        expect(page).to have_selector('tr:nth-child(1) td', :text => 'Brunete')
      end
    end

    context 'Income => Specific Budget Lines' do
      ranking_url = '/ranking/2012/I/economic/amount_per_inhabitant/7'

      scenario 'without specifying a given Place, Segura de los Baños is first' do
        visit ranking_url
        expect(page).to have_selector('tr:first', text: 'Segura de los Baños')
      end

      scenario 'specifying a given Place, it redirects to the page where that Place appears in the ranking' do
        visit "#{ranking_url}?ine_code=28026"
        expect(page).to have_current_path("#{ranking_url}?ine_code=28026&page=236")
      end

      scenario 'specifying a given Place, the place is highlighted' do
        visit "#{ranking_url}?ine_code=28026"
        expect(page).to have_css('tr#place_28026.selected')
      end

      scenario 'with mixed filters' do
        params = {
          ine_code: 28026,
          f: {
            aarr: 13,
            population:     { from: 1_000, to: 25_000},
            total:          { from: 0, to: 50_000},
            per_inhabitant: { from: 0, to: 500}
          }
        }

        visit "#{ranking_url}?#{params.to_query}"
        expect(page).to have_selector('tr:nth-child(7) td', :text => 'Brunete')
      end
    end
  end
end
