require 'rails_helper'

RSpec.feature 'Homepage' do
  before do
    switch_to_subdomain 'presupuestos'
  end

  scenario 'Visit homepage', js: true do
    visit '/'

    expect(page).to have_content('Presupuestos Municipales')
    fill_autocomplete('.pre_home .places_search', page, with: 'madri', select: 'Madrid')

    expect(page).to have_content('Madridejos')
    expect(page).to have_css("ul#history li", text: 'Madridejos (2015)')
  end
end
