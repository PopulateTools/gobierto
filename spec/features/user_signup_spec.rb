require 'rails_helper'

RSpec.feature 'User signup' do
  before do
    switch_to_subdomain 'presupuestos'
  end

  scenario "Signup via 'levanta la mano' and account confirmation", js: true do
    visit '/budget_lines/santander/2015/1/G/economic'
    click_link 'Levanta la mano'
    click_link 'No'

    fill_in 'user_email', with: 'bar@example.com'
    click_button 'Seguir'

    expect(page).to have_content('Comprueba tu correo')

    open_last_email_for 'bar@example.com'
    email = current_email
    expect(email).to have_body_text(/Por favor confirma tu email pinchando en el siguiente enlace/)
    click_email_link_matching /verify/

    expect(page).to have_content("Venga, ya casi estamos")

    fill_in 'user_password', with: 'bar123456'
    fill_in 'user_password_confirmation', with: 'bar123456'
    check 'He leído el Aviso legal y la Política de privacidad'
    # By default the first elements of the list are loaded
    select 'Almería', from: 'user_place_id'
    click_button 'Enviar'

    expect(page).to have_content("Datos actualizados correctamente")
    user = User.find_by email: 'bar@example.com'
    expect(user.place_id).to eq(4013)
  end

  scenario "Signup and verify via 'Eres responsable de este municipio?'" do
    visit 'places/madrid/2015'

    within :css, '.pro_user' do
      click_link "Solicita información"
    end

    expect(page).to have_select "Tu municipio", :selected => 'Madrid'
    expect(page).to have_checked_field "Profesional de la administración local"
    expect(page).to have_unchecked_field "He leído el Aviso legal y la Política de privacidad"

    fill_in 'E-mail', with: 'jorge@example.com'
    check 'He leído el Aviso legal y la Política de privacidad'

    click_button 'Enviar'

    expect(page).to have_content("Por favor, confirma tu email")

    user = User.find_by email: 'jorge@example.com'
    expect(user.place_id).to eq(28079)
    expect(user.pro).to be true
    expect(user.terms_of_service).to be true

    open_last_email_for 'jorge@example.com'
    email = current_email
    expect(email).to have_body_text(/Por favor confirma tu email pinchando en el siguiente enlace/)
    click_email_link_matching /verify/

    expect(page).to have_content "Venga, ya casi estamos"
    expect(page).not_to have_unchecked_field "He leído el Aviso legal y la Política de privacidad"

    fill_in 'user_password', with: 'bar123456'
    fill_in 'user_password_confirmation', with: 'bar123456'

    click_button 'Enviar'
    expect(page).to have_content "Datos actualizados correctamente"
  end

  scenario "Signup and verify via 'Pide a tu ayuntamiento'" do
    visit 'places/santander/2015'

    within('.end_user') do
      click_link "Pide a tu ayuntamiento"
    end

    expect(page).to have_content "Pide que tu alcalde añada información"

    expect(page).to have_select "Tu municipio", :selected => 'Santander'
    expect(page).to have_checked_field "Ciudadano"
    expect(page).to have_unchecked_field "He leído el Aviso legal y la Política de privacidad"

    fill_in 'E-mail', with: 'jorge@example.com'
    uncheck 'He leído el Aviso legal y la Política de privacidad' #We can sign-up without accepting, it will be required on verification

    click_button 'Enviar'

    expect(page).to have_content("Por favor, confirma tu email")

    user = User.find_by email: 'jorge@example.com'
    expect(user.place_id).to eq(39075)
    expect(user.pro).to be false
    expect(user.terms_of_service).to be false

    open_last_email_for 'jorge@example.com'
    email = current_email
    expect(email).to have_body_text(/Por favor confirma tu email pinchando en el siguiente enlace/)
    click_email_link_matching /verify/

    expect(page).to have_content "Venga, ya casi estamos"
    expect(page).to have_unchecked_field "He leído el Aviso legal y la Política de privacidad"

    click_button 'Enviar'
    expect(page).to have_content "No se han podido actualizar los datos"

    fill_in 'user_password', with: 'bar123456'
    fill_in 'user_password_confirmation', with: 'bar123456'

    check 'He leído el Aviso legal y la Política de privacidad'
    click_button 'Enviar'
  end
end
