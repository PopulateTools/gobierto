class User::Notification < ApplicationRecord
  belongs_to :user
  belongs_to :site
  belongs_to :subject, polymorphic: true

  scope :sorted, -> { order(created_at: :desc) }
  scope :sent,   -> { where(sent: true) }
  scope :unsent, -> { where(sent: false) }

  def self.sent!
    update_all(sent: true)
  end

  def self.unsent!
    update_all(sent: false)
  end

  def sent!
    update_columns(sent: true)
  end

  def unsent!
    update_columns(sent: false)
  end
end
