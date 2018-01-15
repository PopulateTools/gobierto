# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
                                       key: "_gobierto_session",
                                       tld_length: ENV.fetch("TLD_LENGTH") { "2" }.to_i
