require 'rails_helper'

RSpec.feature 'Gobierto CMS module' do
  before do
    @site = create_site
    parent_page = create_gobierto_cms_page site: @site, title: 'Sobre el ayuntamiento', body: 'El ayuntamiento de Villaconejo...'
    page = create_gobierto_cms_page site: @site, parent: parent_page, title: 'Sobre el alcalde', body: 'El alcalde de Villaconejo...'

    switch_to_subdomain @site.subdomain
  end

  scenario 'Visit a page and visit the children and the root', js: true do
    visit '/paginas'

    within(:css, '.main') do
      click_link 'Sobre el ayuntamiento'
    end

    expect(page).to have_content('Sobre el ayuntamiento')
    expect(page).to have_content('El ayuntamiento de Villaconejo...')

    click_link 'Sobre el alcalde'

    expect(page).to have_content('Sobre el alcalde')
    expect(page).to have_content('El alcalde de Villaconejo...')

    click_link 'Inicio'

    within(:css, '.main') do
      expect(page).to have_content('Sobre el ayuntamiento')
    end
  end

  scenario 'Layout menu should include root pages' do
    visit '/paginas'

    within(:css, 'menu.global') do
      expect(page).to have_content('Sobre el ayuntamiento')
      expect(page).not_to have_content('Sobre el alcalde')
    end
  end
end
