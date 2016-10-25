module DomainHelpers
  def set_host(host)
    default_url_options[:host] = host
    Capybara.app_host = "http://" + host
  end
end

RSpec.configure do |c|
  c.include DomainHelpers
end
