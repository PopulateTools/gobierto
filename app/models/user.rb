class User < ApplicationRecord
  include Authentication::Authenticable
  include Authentication::Confirmable
  include Authentication::Recoverable
  include Session::Trackable

  EMAIL_ADDRESS_REGEXP = /\A(.+)@(.+\..+)\z/

  belongs_to :source_site, class_name: "Site"

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
    format: { with: EMAIL_ADDRESS_REGEXP }

  scope :sorted, -> { order(created_at: :desc) }

  # TODO. Implement this behavior.
  def verified?
    false
  end
end
