# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
  key: "_updated_gobierto_session",
  domain: Rails.env.test? ? :all : ENV.fetch("DOMAIN") { ".gobierto.dev" },
  tld_length: ENV.fetch("TLD_LENGTH") { "2" }.to_i
