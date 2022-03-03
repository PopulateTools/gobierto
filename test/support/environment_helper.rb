# frozen_string_literal: true

module EnvironmentHelper
  def with_environment(replacement_env)
    original_env = ENV.to_hash
    ENV.update(replacement_env)

    yield
  ensure
    ENV.replace(original_env)
  end
end
