module Authentication::Authenticable
  extend ActiveSupport::Concern

  included do
    has_secure_password validations: false

    scope :with_password, -> { where.not(password_digest: nil) }
  end
end
