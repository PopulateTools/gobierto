# frozen_string_literal: true

class User::Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :site
  belongs_to :subscribable, polymorphic: true

  validates :user_id, :site_id, presence: true
  validates :subscribable_type, presence: true

  scope :specific, -> { where.not(subscribable_id: nil) }
  scope :generic,  -> { where(subscribable_id: nil) }
  scope :sorted,   -> { order(created_at: :desc) }

  delegate :subscribable_label, to: :subscribable

  def specific?
    subscribable_id.present?
  end

  def generic?
    !specific?
  end

  # Overrides polymorphic association in generic subscriptions.
  #
  def subscribable
    generic? ? subscribable_type.constantize : super
  end
end
