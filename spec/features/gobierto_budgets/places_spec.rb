require 'rails_helper'

RSpec.feature 'Places spec' do
  before do
    switch_to_subdomain 'presupuestos'
  end

  scenario 'Visit a place without data' do
    visit '/places/castejon-cuenca/2015'
    expect(page).to have_css('h1', text: 'Castejón')
    expect(page).to have_content('No tenemos datos sobre este municipio para este año')

    click_link '2011'
    expect(page).to have_css('h1', text: 'Castejón')
    expect(page).to_not have_content('No tenemos datos sobre este municipio para este año')
  end
end
