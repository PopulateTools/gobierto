# frozen_string_literal: true

class User::ApiToken < ApplicationRecord
  belongs_to :user
  has_secure_token
  validates :user, presence: true
  validates :name, presence: true, unless: :primary?
  validates :name, uniqueness: { scope: :user }
  validates :user, uniqueness: { scope: :primary }, if: :primary?

  delegate :site, to: :user

  scope :primary, -> { where(primary: true) }
end
