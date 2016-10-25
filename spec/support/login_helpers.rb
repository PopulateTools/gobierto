module LoginHelpers
  def login_as(email, password)
    visit '/login'

    fill_in 'session_email', with: email
    fill_in 'session_password', with: password

    click_button 'Enviar'
  end
end

RSpec.configure do |c|
  c.include LoginHelpers
end
