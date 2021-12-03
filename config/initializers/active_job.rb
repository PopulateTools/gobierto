# frozen_string_literal: true

if ENV["ENABLE_LOG_RAGE"].present?
  ActiveJob::Base.logger = Logger.new(IO::NULL)
end
