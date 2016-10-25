require 'rails_helper'

RSpec.feature 'User feedback' do
  before do
    switch_to_subdomain 'presupuestos'
    @user = create_user first_name: 'Foo', last_name: 'Wadus'
  end

  scenario 'Anonymous user responds no on a budget line', js: true do
    visit '/budget_lines/santander/2015/1/G/economic'
    click_link 'Levanta la mano'
    click_link 'No'

    sleep 2

    expect(page).to have_content('Puedes solicitar a tu alcalde que amplie la información sobre esta y otras partidas')

    fill_in 'user_email', with: 'bar@example.com'
    click_button 'Seguir'

    expect(page).to have_content('Comprueba tu correo')
  end

  scenario 'Anonymous user gives feedback on a budget line', js: true do
    visit '/budget_lines/santander/2015/1/G/economic'
    click_link 'Levanta la mano'
    click_link 'Sí'
    click_link 'Me parece POCO'

    expect(page).to have_content('Gracias por tu opinión')
    expect(page).to have_content('100.0% POCO')
    expect(page).to have_content('0% APROPIADO')
    expect(page).to have_content('0% MUCHO')

    fill_in 'user_email', with: 'bar@example.com'
    click_button 'Seguir'

    expect(page).to have_content('Comprueba tu correo')
  end

  scenario 'Logged user gives feedback on a budget line', js: true do
    login_as 'foo@example.com', 'foo123456'

    visit '/budget_lines/santander/2015/1/G/economic'
    click_link 'Levanta la mano'
    click_link 'Sí'
    click_link 'Me parece POCO'

    expect(page).to have_content('Gracias por tu opinión')
    expect(page).to have_content('100.0% POCO')
    expect(page).to have_content('0% APROPIADO')
    expect(page).to have_content('0% MUCHO')

    expect(page).to_not have_css('#new_user')
    expect(GobiertoBudgets::Answer.last.user_id).to eq(@user.id)
  end

  scenario 'Logged user visits budget line with her feedback', js: true do
    place = INE::Places::Place.find_by_slug 'santander'

    GobiertoBudgets::Answer.create answer_text: 'Sí', question_id: 1, user_id: @user.id, place_id: place.id, year: 2015, code: 1, area_name: 'economic', kind: 'G'
    GobiertoBudgets::Answer.create answer_text: 'Apropiado', question_id: 2, user_id: @user.id, place_id: place.id, year: 2015, code: 1, area_name: 'economic', kind: 'G'
    GobiertoBudgets::Answer.create answer_text: 'Apropiado', question_id: 2, user_id: @user.id, place_id: place.id, year: 2014, code: 1, area_name: 'economic', kind: 'G'

    login_as 'foo@example.com', 'foo123456'

    visit "/budget_lines/#{place.slug}/2015/1/G/economic"
    click_link 'Levanta la mano'

    expect(page).to have_content('Gracias por tu opinión')
    expect(page).to have_content('0% POCO')
    expect(page).to have_content('100.0% APROPIADO')
    expect(page).to have_content('0% MUCHO')

    expect(page).to_not have_css('#new_user')
  end

  scenario 'Logged user visits budget line when replied No', js: true do
    login_as 'foo@example.com', 'foo123456'

    visit '/budget_lines/santander/2015/1/G/economic'
    click_link 'Levanta la mano'
    click_link 'No'

    expect(page).to_not have_content('Puedes solicitar a tu alcalde que amplie la información sobre esta y otras partidas')
    expect(page).to have_content('El 100.0% de personas han respondido que No')

    expect(page).to_not have_css('#new_user')
    expect(GobiertoBudgets::Answer.last.user_id).to eq(@user.id)
  end

  scenario 'Anonymous user logs in when giving feedback', js: true do
    visit '/budget_lines/santander/2015/1/G/economic'
    click_link 'Levanta la mano'
    click_link 'No'

    sleep 3

    expect(page).to have_content('Puedes solicitar a tu alcalde que amplie la información sobre esta y otras partidas')
    expect(page).to have_content('El 100.0% de personas han respondido que No')

    fill_in 'user_email', with: 'foo@example.com'
    click_button 'Seguir'
    expect(page).to have_content('Parece que ya tienes cuenta en Gobierto')
    fill_in 'session_password', with: 'foo123456'
    click_button 'Enviar'
  end

end
