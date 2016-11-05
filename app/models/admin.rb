class Admin < ApplicationRecord
  include Authentication::Authenticable
  include Authentication::Confirmable

  EMAIL_ADDRESS_REGEXP = /\A(.+)@(.+\..+)\z/

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
    format: { with: EMAIL_ADDRESS_REGEXP }

  enum authorization_level: { regular: 0, manager: 1 }
end
