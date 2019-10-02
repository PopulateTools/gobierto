# frozen_string_literal: true

class ApiConstraint
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
    @domain = options[:domain] || :gobierto
  end

  def matches?(req)
    @default || req.headers["Accept"].include?("application/vnd.#{ @domain }+json; version=#{ @version }")
  end
end
