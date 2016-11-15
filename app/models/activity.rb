class Activity < ApplicationRecord

  belongs_to :subject, polymorphic: true
  belongs_to :author, polymorphic: true
  belongs_to :recipient, polymorphic: true

  validates :action, presence: true
  validates :subject_ip, presence: true
  validates :admin_activity, presence: true

  scope :sorted, -> { order(id: :desc) }
  scope :admin, -> { where(admin_activity: true) }
  scope :global, -> { where(site_id: nil) }
  scope :in_site, ->(site_id) { where(site_id: site_id) }

  def self.global_admin_activities
    global.admin.sorted.includes(:subject, :author, :recipient)
  end

  def self.admin_activities(admin)
    where(author_type: admin.class.name, author_id: admin.id).sorted.includes(:subject, :author, :recipient)
  end

end
