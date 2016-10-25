require 'rails_helper'

RSpec.feature 'Admin actions in Gobierto Participation module' do
  before do
    @site = create_site

    @admin = create_admin first_name: "Admin", last_name: "Órgiva"
    @user = create_user first_name: 'María Del Pilar', email: 'mariadelpilar@example.com', password: 'mariadelpilar'
    @commenter = create_user first_name: 'Pedro Soler', email: 'pedrosoler@example.com', password: 'pedrosoler'

    switch_to_subdomain @site.subdomain
  end

  scenario 'Edit an idea' do
    idea = GobiertoParticipation::Idea.create! title: "¿Qué vamos a hacer para esta Navidad?",
              body: 'Ya se acercan las fiestas y es momento', site: @site, user: @user

    visit '/'

    login_as 'admin@example.com', 'adminadmin'

    visit '/participacion/ideas'

    click_link '¿Qué vamos a hacer para esta Navidad?'

    click_link 'Editar'

    fill_in 'gobierto_participation_idea_title', with: '¿Qué vamos a hacer para estas Navidades?'

    click_button 'Actualizar'

    expect(page).to have_content('¿Qué vamos a hacer para estas Navidades?')
  end

  scenario 'Delete an idea' do
    idea = GobiertoParticipation::Idea.create! title: "¿Qué vamos a hacer para esta Navidad?",
              body: 'Ya se acercan las fiestas y es momento', site: @site, user: @user


    visit '/'

    login_as 'admin@example.com', 'adminadmin'

    visit '/participacion/ideas'

    click_link '¿Qué vamos a hacer para esta Navidad?'

    click_link 'Eliminar'

    expect(page).to have_content('Ideas')
    expect(page).to_not have_content('¿Qué vamos a hacer para estas Navidades?')
  end

  scenario 'Edit an open answers consultation' do
    consultation = create_gobierto_participation_open_answers_consultation site: @site, open_until: 3.months.from_now, user: @admin

    visit '/'

    login_as 'admin@example.com', 'adminadmin'

    visit '/participacion/consultas'

    click_link '¿Cómo se debería de llamar la calle nueva?'

    click_link 'Editar'

    fill_in 'gobierto_participation_consultation_title', with: '¿Qué nombre le ponemos a la calle nueva?'

    click_button 'Actualizar'

    expect(page).to have_content('¿Qué nombre le ponemos a la calle nueva?')
  end

  scenario 'Delete an open answers consultation' do
    consultation = create_gobierto_participation_open_answers_consultation site: @site, open_until: 3.months.from_now, user: @admin

    visit '/'

    login_as 'admin@example.com', 'adminadmin'

    visit '/participacion/consultas'

    click_link '¿Cómo se debería de llamar la calle nueva?'

    click_link 'Eliminar'

    expect(page).to have_content('Consultas')
    expect(page).to_not have_content('¿Cómo se debería de llamar la calle nueva?')
  end

  # TODO:
  # scenario 'Edit a closed answers consultation and remove an option', js: true do
  #   create(:gobierto_participation_closed_answers_consultation)
  #
  #   visit '/participacion/consultas'
  #
  #   click_link 'Tu Cuenta'
  #
  #   login_as 'admin@example.com', 'adminadmin'
  #
  #   visit '/participacion/consultas'
  #
  #   click_link '¿Cómo se debería de llamar la calle nueva?'
  #
  #   click_link 'Editar'
  #
  #   # TODO
  #   debugger
  #   page.first('label[for="gobierto_participation_consultation_options_attributes_0_option"]').click
  #   #page.first('a.remove_option').click
  #
  #   click_button 'Actualizar'
  # end

  scenario 'Delete a closed answers consultation' do
    consultation = create_gobierto_participation_closed_answers_consultation site: @site, open_until: 3.months.from_now, user: @admin

    visit '/'

    login_as 'admin@example.com', 'adminadmin'

    visit '/participacion/consultas'

    click_link '¿Cómo se debería de llamar la calle nueva?'

    click_link 'Eliminar'

    expect(page).to have_content('Consultas')
    expect(page).to_not have_content('¿Cómo se debería de llamar la calle nueva?')
  end
end
