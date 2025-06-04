# frozen_string_literal: true

class RateLimitLogger
  def initialize(logger = Rails.logger)
    @logger = logger
  end

  def info(message)
    @logger.info "[rate_limit_hit] #{message}"
  end
end
