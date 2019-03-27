# frozen_string_literal: true

module Authentication::Authenticable
  extend ActiveSupport::Concern

  included do
    has_secure_password validations: false
  end
end
