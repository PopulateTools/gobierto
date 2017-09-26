class Activity < ApplicationRecord
  paginates_per 50

  belongs_to :subject, polymorphic: true
  belongs_to :author, polymorphic: true
  belongs_to :recipient, polymorphic: true
  belongs_to :site

  validates :action, presence: true
  validates :subject_ip, presence: true
  validates :admin_activity, inclusion: { in: [true, false] }

  scope :sorted, -> { order(id: :desc) }
  scope :admin, -> { where(admin_activity: true) }
  scope :global, -> { where(site_id: nil) }
  scope :in_site, ->(site_id) { where(site_id: site_id) }
  scope :for_recipient, ->(recipient) { where(recipient: recipient) }

  def self.global_admin_activities
    global.admin.sorted.includes(:subject, :author, :recipient)
  end

  def self.admin_activities(admin)
    where(author_type: admin.class.name, author_id: admin.id).sorted.includes(:subject, :author, :recipient)
  end

  def self.participation
    where("subject_type LIKE 'GobiertoParticipation%' OR
           subject_type LIKE 'Issue'")
  end
end
