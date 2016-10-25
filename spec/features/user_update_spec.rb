require 'rails_helper'

RSpec.feature 'User update' do
  before do
    switch_to_subdomain 'presupuestos'
  end

  scenario 'user does not need to enter his password to update rest of his details' do
    user = create_user first_name: 'Marcus', email: 'marcus_aurelius@example.com',
            password: 'emperor_61', password_confirmation: 'emperor_61'
    visit '/login'

    fill_in 'Email', with: 'marcus_aurelius@example.com'
    fill_in 'Contraseña', with: 'emperor_61'

    click_button 'Enviar'

    expect(page).to have_content('Hola Marcus')
    click_link 'Editar datos personales'

    fill_in 'Apellidos', with: 'Aurelius'
    choose 'Profesional'

    click_button 'Enviar'
    expect(page).to have_content('Datos actualizados correctamente')
  end
end
