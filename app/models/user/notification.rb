class User::Notification < ApplicationRecord
  belongs_to :user
  belongs_to :site
  belongs_to :subject, polymorphic: true

  scope :sorted, -> { order(created_at: :desc) }
  scope :sent,   -> { where(sent: true) }
  scope :unsent, -> { where(sent: false) }
  scope :seen,   -> { where(is_seen: true) }
  scope :unseen, -> { where(is_seen: false) }

  def self.sent!
    update_all(sent: true)
  end

  def self.unsent!
    update_all(sent: false)
  end

  def self.seen!
    update_all(is_seen: true)
  end

  def self.unseen!
    update_all(is_seen: false)
  end

  def sent!
    update_columns(sent: true)
  end

  def unsent!
    update_columns(sent: false)
  end

  def seen?
    is_seen
  end

  def seen!
    update_columns(is_seen: true)
  end

  def unseen!
    update_columns(is_seen: false)
  end
end
