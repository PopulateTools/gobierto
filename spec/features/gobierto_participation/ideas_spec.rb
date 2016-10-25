require 'rails_helper'

RSpec.feature 'Gobierto Participation Ideas module' do
  before do
    @site = create_site

    @user = create_user first_name: 'María Del Pilar', email: 'mariadelpilar@example.com', password: 'mariadelpilar'
    @commenter = create_user first_name: 'Pedro Soler', email: 'pedrosoler@example.com', password: 'pedrosoler'

    switch_to_subdomain @site.subdomain
  end

  scenario 'Visit an idea and comment' do
    idea = GobiertoParticipation::Idea.create! title: "¿Qué vamos a hacer para esta Navidad?",
              body: 'Ya se acercan las fiestas y es momento', site: @site, user: @user
    GobiertoParticipation::Comment.create body: "<p>Bravo</p>", site: @site, user: @commenter, commentable: idea

    visit '/participacion/ideas'

    expect(page).to have_content('Últimas ideas publicadas')
    expect(page).to have_content('¿Qué vamos a hacer para esta Navidad?')
    expect(page).to have_content('María Del Pilar')

    click_link '¿Qué vamos a hacer para esta Navidad?'

    expect(page).to have_content('¿Qué vamos a hacer para esta Navidad?')
    expect(page).to have_content('Ya se acercan las fiestas y es momento')

    expect(page).to have_content('1 comentario')
    expect(page).to have_content('Bravo')
    expect(page).to have_content('Enviado por Pedro Soler')

    login_as 'mariadelpilar@example.com', 'mariadelpilar'

    visit "/participacion/ideas/que-vamos-a-hacer-para-esta-navidad"

    expect(page).to have_content('¿Qué vamos a hacer para esta Navidad?')

    fill_in 'gobierto_participation_comment_body', with: 'Yo haría fiesta grande en la plaza'
    click_button 'Enviar'

    expect(page).to have_content('¿Qué vamos a hacer para esta Navidad?')
    expect(page).to have_content('2 comentarios')
    expect(page).to have_content('Yo haría fiesta grande en la plaza')
    expect(page).to have_content('Enviado por María Del Pilar')
  end

  scenario 'Create a new idea' do
    visit '/participacion/ideas'

    expect(page).to have_content('Últimas ideas publicadas')

    login_as 'mariadelpilar@example.com', 'mariadelpilar'

    visit '/participacion/ideas'

    click_link 'Envía tu idea'

    expect(page).to have_content('Envía una nueva idea')

    fill_in 'gobierto_participation_idea_title', with: 'Contenedores de reciclaje'
    fill_in 'gobierto_participation_idea_body', with: '<p>Me gustaría proponer contenedores de reciclaje en la plaza</p>'
    click_button 'Crear'

    expect(page).to have_content('Contenedores de reciclaje')
    expect(page).to have_content('0 comentarios')
    expect(page).to have_content('Idea enviada por María Del Pilar')

    fill_in 'gobierto_participation_comment_body', with: '¿Qué os parece?'
    click_button 'Enviar'

    expect(page).to have_content('Contenedores de reciclaje')
    expect(page).to have_content('1 comentario')
  end
end
