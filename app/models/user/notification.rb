class User::Notification < ApplicationRecord
  belongs_to :user
  belongs_to :site
  belongs_to :subject, polymorphic: true

  scope :sorted, -> { order(created_at: :desc) }
end
