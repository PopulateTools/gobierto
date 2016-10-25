require 'rails_helper'

RSpec.feature 'Admin actions in Gobierto CMS module' do
  before do
    @site = create_site
    create_admin
    switch_to_subdomain @site.subdomain
  end

  scenario 'New page root and child page' do
    visit '/'

    login_as 'admin@example.com', 'adminadmin'

    visit '/admin/cms/pages'

    click_link 'Crear'

    fill_in "gobierto_cms_page_title", with: "Sobre el ayuntamiento"
    fill_in "gobierto_cms_page_body", with: "Bienvenidos al ayuntamiento de [Órgiva](http://www.aytoorgiva.org/web/)"
    click_button "Enviar"

    expect(page).to have_content("Página creada correctamente")

    click_link 'Crear'

    fill_in "gobierto_cms_page_title", with: "Sobre el alcalde"
    fill_in "gobierto_cms_page_body", with: "Hola a todos, soy el alcalde"
    select "Sobre el ayuntamiento", from: "gobierto_cms_page_parent_id"
    click_button "Enviar"

    expect(page).to have_content("Página creada correctamente")

    # Page is in a level down
    expect(page).to have_css("ul li ul li .page", text: "Sobre el alcalde")
  end

  scenario 'Edit a page' do
    create_gobierto_cms_page site: @site, title: 'Sobre el ayuntamiento', body: 'El ayuntamiento de Villaconejo...'

    visit '/'

    login_as 'admin@example.com', 'adminadmin'

    visit '/admin/cms/pages'

    click_link 'Editar'

    fill_in "gobierto_cms_page_title", with: "Sobre el ayuntamiento updated"
    click_button "Enviar"

    expect(page).to have_content("Página actualizada correctamente")
    expect(page).to have_content("Sobre el ayuntamiento updated")
  end

  scenario 'Delete a page' do
    create_gobierto_cms_page site: @site, title: 'Sobre el ayuntamiento', body: 'El ayuntamiento de Villaconejo...'

    visit '/'

    login_as 'admin@example.com', 'adminadmin'

    visit '/admin/cms/pages'

    expect(page).to have_content("Sobre el ayuntamiento")

    click_link 'Borrar'

    expect(page).to have_content("Página eliminada correctamente")
    expect(page).to_not have_content("Sobre el ayuntamiento")
  end

end
