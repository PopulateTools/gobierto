# frozen_string_literal: true

InvisibleCaptcha.setup do |config|
  config.honeypots << %w(ic_email)
  config.sentence_for_humans = false
  config.timestamp_threshold = Rails.env.test? ? 0 : 0.5
  config.visual_honeypots = false
end
