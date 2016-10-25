require 'rails_helper'

RSpec.feature 'Admin actions' do
  before do
    @site = create_site
    create_admin
    switch_to_subdomain @site.subdomain
  end

  pending 'Edit user data from the list of users' do
    u1 = create_user first_name: 'María Del Pilar', email: 'mariadelpilar@example.com', password: 'mariadelpilar'
    u2 = create_commenter first_name: 'Pedro', last_name: 'Soler', email: 'pedrosoler@example.com', password: 'pedrosoler'

    visit '/'

    login_as 'admin@example.com', 'adminadmin'

    click_link 'Administración', match: :first

    click_link 'Usuarios'

    expect(page).to have_content('María Del Pilar')
    expect(page).to have_content('mariadelpilar@example.com')

    expect(page).to have_content('Pedro Soler')
    expect(page).to have_content('pedrosoler@example.com')

    within(:css, "tr[data-id='#{u1.id}']") do |row|
      click_link 'Editar información del usuario'
    end

    fill_in 'user_first_name', with: 'Carmena'
    fill_in 'user_email', with: 'carmena@example.com'
    click_button 'Enviar'

    expect(page.find('#user_first_name').value).to eq('Carmena')
    expect(page.find('#user_email').value).to eq('carmena@example.com')
  end

  pending 'Complete an user signup from the list of users' do
    visit '/participacion'

    fill_in 'user_email', with: 'fernando@example.com'
    click_button 'Regístrate'

    visit '/'

    login_as 'admin@example.com', 'adminadmin'

    click_link 'Administración', match: :first
    click_link 'Usuarios'

    user_id = User.last.id

    within(:css, "[data-id=\"#{user_id}\"]") do
      click_link 'Editar información del usuario'
    end

    fill_in 'user_first_name', with: 'Manuela'
    fill_in 'user_last_name', with: 'Carmena'
    fill_in 'user_password', with: 'manuela'
    fill_in 'user_password_confirmation', with: 'manuela'

    click_button 'Enviar'

    expect(page.find('#user_first_name').value).to eq('Manuela')
    expect(page.find('#user_email').value).to eq('fernando@example.com')

    u = User.find_by email: 'fernando@example.com'
    expect(u).to be_valid
  end

  pending 'Impersonate as a user' do
    u1 = create_user first_name: 'María Del Pilar', email: 'mariadelpilar@example.com'
    u2 = create_commenter first_name: 'Pedro', last_name: 'Soler', email: 'pedrosoler@example.com'

    visit '/'

    login_as 'admin@example.com', 'adminadmin'

    click_link 'Administración', match: :first
    click_link 'Usuarios'

    expect(page).to have_content('María Del Pilar')
    expect(page).to have_content('mariadelpilar@example.com')

    expect(page).to have_content('Pedro Soler')
    expect(page).to have_content('pedrosoler@example.com')

    within(:css, "tr[data-id='#{u1.id}']") do |row|
      click_link 'Loguearse como el usuario'
    end

    expect(page).to have_content('María Del Pilar (admin)')

    click_link 'Desconectar'

    click_link 'Administración', match: :first
    click_link 'Usuarios'

    expect(page).to have_content('María Del Pilar')
    expect(page).to have_content('mariadelpilar@example.com')
  end

  pending 'Soft delete an user' do
    u1 = create_user first_name: 'María Del Pilar', email: 'mariadelpilar@example.com'

    visit '/'

    login_as 'admin@example.com', 'adminadmin'

    click_link 'Administración', match: :first
    click_link 'Usuarios'

    expect(page).to have_content('María Del Pilar')
    expect(page).to have_content('mariadelpilar@example.com')

    within(:css, "tr[data-id='#{u1.id}']") do |row|
      click_link "Eliminar usuario: no podrá hacer login ni publicar contenido; su actividad desaparecerá (seguirá visible para administradores)"
    end

    click_link 'Desconectar'

    login_as 'mariadelpilar@example.com', 'mariadelpilar'

    expect(page).to_not have_content('María Del Pilar')

    login_as 'admin@example.com', 'adminadmin'

    click_link 'Administración', match: :first
    click_link 'Usuarios'

    expect(page).to have_content('María Del Pilar')
    expect(page).to have_content('mariadelpilar@example.com')
    within(:css, "tr[data-id='#{u1.id}']") do |row|
      click_link "Restaurar usuario: volverá a poder hacer login y a publicar; su actividad volverá a ser pública"
    end

    click_link 'Desconectar'

    login_as 'mariadelpilar@example.com', 'mariadelpilar'

    expect(page).to have_content('María Del Pilar')
  end

  pending 'Edit site information' do
    visit '/'

    login_as 'admin@example.com', 'adminadmin'

    click_link 'Administración', match: :first
    click_link 'Configuración'

    fill_in 'site_institution_type', with: 'Fundación'
    click_button 'Enviar'

    expect(page.find('#site_institution_type').value).to eq('Fundación')
    expect(page.find('#site_subdomain').value).to eq('orgiva')
  end

end
