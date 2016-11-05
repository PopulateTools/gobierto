module Authentication::Authenticable
  extend ActiveSupport::Concern

  included do
    has_secure_password
  end
end
