class Activity < ApplicationRecord

  belongs_to :subject, polymorphic: true
  belongs_to :author, polymorphic: true
  belongs_to :recipient, polymorphic: true

  validates :action, presence: true
  validates :subject_ip, presence: true
  validates :admin_activity, presence: true

end
