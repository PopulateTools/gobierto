# frozen_string_literal: true

Liquid::Template.error_mode = :lax

Dir[Rails.root.join("lib/liquid/**/*.rb")].each { |file| require file }
