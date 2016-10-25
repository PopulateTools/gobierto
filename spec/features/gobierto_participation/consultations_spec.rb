require 'rails_helper'

RSpec.feature 'Gobierto Participation Consultations module' do
  before do
    @site = create_site

    @admin = create_admin first_name: "Admin", last_name: "Órgiva"
    @user = create_user first_name: 'María Del Pilar', email: 'mariadelpilar@example.com', password: 'mariadelpilar'
    @commenter = create_user first_name: 'Pedro Soler', email: 'pedrosoler@example.com', password: 'pedrosoler'

    switch_to_subdomain @site.subdomain
  end

  scenario 'Visit an open consultation and give an answer' do
    Timecop.freeze(Time.local(2015,10,29,17,50))

    consultation = create_gobierto_participation_open_answers_consultation site: @site, open_until: 3.months.from_now, user: @admin

    visit '/participacion/consultas'

    expect(page).to have_content('Últimas consultas publicadas')
    expect(page).to have_content('¿Cómo se debería de llamar la calle nueva?')
    expect(page).to have_content('Votaciones hasta 29 ene 2016')

    click_link '¿Cómo se debería de llamar la calle nueva?'

    expect(page).to have_content('¿Cómo se debería de llamar la calle nueva?')
    expect(page).to have_content('Vamos a inaugurar una calle nueva')

    login_as 'mariadelpilar@example.com', 'mariadelpilar'

    visit '/participacion/consultas/como-se-deberia-de-llamar-la-calle-nueva'

    fill_in 'gobierto_participation_consultation_answer_answer', with: 'Calle Palencia'
    fill_in 'gobierto_participation_consultation_answer_comment', with: 'Porque es la que sale directamente a Palencia'
    click_button 'Enviar'

    expect(page).to have_content('1 propuesta')
    expect(page).to have_content('Calle Palencia')
    expect(page).to have_content('Porque es la que sale directamente a Palencia')
  end

  scenario 'Visit an open consultation closed and give an answer' do
    Timecop.freeze(Time.local(2015,5,29,17,50))

    consultation = create_gobierto_participation_open_answers_consultation site: @site, open_until: 1.day.from_now, user: @admin
    consultation.answers.create! user: @commenter, answer: 'Una respuesta cualquiera', site: @site

    Timecop.freeze(Time.local(2015,10,29,17,50))

    visit '/participacion/consultas'

    expect(page).to have_content('Últimas consultas publicadas')
    expect(page).to have_content('¿Cómo se debería de llamar la calle nueva?')
    expect(page).to have_content('5 meses')

    click_link '¿Cómo se debería de llamar la calle nueva?'

    expect(page).to have_content('¿Cómo se debería de llamar la calle nueva?')
    expect(page).to have_content('Vamos a inaugurar una calle nueva')

    login_as 'mariadelpilar@example.com', 'mariadelpilar'

    visit '/participacion/consultas/como-se-deberia-de-llamar-la-calle-nueva'

    expect(page).to have_content('1 propuesta')
    expect(page).to have_content('Una respuesta cualquiera')
  end

  scenario 'Visit a closed consultation and give an answer' do
    Timecop.freeze(Time.local(2015,10,29,17,50))

    consultation = create_gobierto_participation_closed_answers_consultation site: @site, open_until: 3.months.from_now, user: @admin

    visit '/participacion/consultas'

    expect(page).to have_content('Últimas consultas publicadas')
    expect(page).to have_content('¿Cómo se debería de llamar la calle nueva?')
    expect(page).to have_content('Votaciones hasta 29 ene 2016')

    click_link '¿Cómo se debería de llamar la calle nueva?'

    login_as 'mariadelpilar@example.com', 'mariadelpilar'
    visit '/participacion/consultas/como-se-deberia-de-llamar-la-calle-nueva'

    choose 'gobierto_participation_consultation_answer_consultation_option_id_1'
    click_button 'Enviar'

    option = consultation.options.first.option

    expect(page).to have_content("100% #{option}")
    expect(page).to have_content('1 respuesta')
  end

  scenario 'As an admin, create a new open consultation' do
    Timecop.freeze(Time.local(2015,10,29,17,50))

    visit '/participacion'

    login_as 'admin@example.com', 'adminadmin'

    visit '/participacion/consultas'

    click_link 'Crear nueva consulta'

    choose 'Consulta abierta'

    fill_in 'gobierto_participation_consultation_title', with: 'Luces de navidad'
    fill_in 'gobierto_participation_consultation_body', with: '<p>Nos parecen muy caras las luces, pero igual la gente quiere</p>'
    fill_in 'gobierto_participation_consultation_open_until_date', with: '10 November, 2015'
    fill_in 'gobierto_participation_consultation_open_until_time', with: '7:30 PM'

    click_button 'Crear'

    expect(page).to have_content('Luces de navidad')
  end

  scenario 'As an admin, create a new closed consultation', js: true do
    Timecop.freeze(Time.local(2015,10,29,17,50))

    visit '/participacion/consultas'

    click_link 'Tu Cuenta'

    login_as 'admin@example.com', 'adminadmin'

    visit '/participacion/consultas'

    click_link 'Crear nueva consulta'

    choose 'Consulta cerrada'

    fill_in 'gobierto_participation_consultation_title', with: 'Luces de navidad'
    fill_in 'gobierto_participation_consultation_body', with: '<p>Nos parecen muy caras las luces, pero igual la gente quiere</p>'

    page.execute_script("$('#gobierto_participation_consultation_open_until_date').val('10 November, 2015')")
    page.execute_script("$('#gobierto_participation_consultation_open_until_time').val('7:30 PM')")

    click_link 'Añadir opción'
    page.find('a.add_fields').click

    inputs = page.all('input').map{|h| h[:id]}.compact.select{|id| id.starts_with?('gobierto_participation_consultation_options_attributes') }
    fill_in inputs.first, with: 'Las ponemos'

    click_link 'Añadir opción'
    inputs = page.all('input').map{|h| h[:id]}.compact.select{|id| id.starts_with?('gobierto_participation_consultation_options_attributes') }
    fill_in inputs.second, with: 'Las quitamos'

    click_button 'Crear'

    expect(page).to have_content('Luces de navidad')
    expect(page).to have_content("Las ponemos")
    expect(page).to have_content("Las quitamos")
    expect(page).to have_content("Votaciones hasta 10 nov 2015")
  end

end
