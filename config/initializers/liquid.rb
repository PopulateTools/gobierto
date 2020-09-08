# frozen_string_literal: true

Liquid::Template.error_mode = :lax

Rails.application.config.to_prepare do
  Dir[Rails.root.join("lib/liquid/**/*.rb")].each {|file| require file }
end
