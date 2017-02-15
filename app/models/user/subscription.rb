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

  def self.find_users_for(subject_type, subject_id, site_id)
    conditions = [{subscribable_type: subject_type, subscribable_id: subject_id, site_id: site_id}]

    if subject_id.present?
      conditions.push({subscribable_type: subject_type, subscribable_id: nil, site_id: site_id})
    end

    if subject_type.include?("::")
      module_name = subject_type.split("::").first
      conditions.push({subscribable_type: module_name, subscribable_id: nil, site_id: site_id})

      main_class = subject_type.split("::").last
      classes = main_class.underscore.split('_')
      if classes.length > 1
        conditions.push({subscribable_type: "#{module_name}::#{classes.first.classify}", site_id: site_id})
      end
    end

    scoped = self.where(conditions.pop)
    while conditions.any?
      scoped = scoped.or(self.where(conditions.pop))
    end
    scoped.pluck(:user_id).uniq
  end
end
