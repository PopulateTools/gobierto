require 'rails_helper'

RSpec.feature 'Follow place spec' do
  before do
    switch_to_subdomain 'presupuestos'
    @user = create_user
  end

  scenario 'Logged user follows a place', js: true do
    login_as 'foo@example.com', 'foo123456'

    visit '/places/santander/2015'
    expect(page).to have_link('0')
    page.execute_script %{ $('#follow_link').click() }
    expect(page).to have_link('1')
  end

  scenario 'Anonymous user follows a place', js: true do
    visit '/places/santander/2015'
    expect(page).to have_link('0')
    page.execute_script %{ $('#follow_link').click() }

    fill_in 'user[email]', :with => 'foo_new@example.com'
    click_button 'Seguir'
    expect(page).to have_content('Haz click en el link que te hemos enviado por email para validar tu cuenta y confirmar tu acción')

    open_last_email_for 'foo_new@example.com'
    email = current_email
    click_email_link_matching /verify/

    fill_in 'user_password', with: 'bar123456'
    fill_in 'user_password_confirmation', with: 'bar123456'
    select 'Almería', from: 'user_place_id'
    check 'He leído el Aviso legal y la Política de privacidad'
    # By default the first elements of the list are loaded

    click_button 'Enviar'

    expect(page).to have_content("Datos actualizados correctamente")

    visit '/places/santander/2015'
    expect(page).to have_link('1')
  end
end
