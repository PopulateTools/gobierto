class Admin::CensusImport < ApplicationRecord
  belongs_to :site
  belongs_to :admin, class_name: "::Admin"

  scope :sorted, -> { order(created_at: :desc) }
  scope :completed, -> { where(completed: true) }

  def self.latest_by_site(site)
    completed.sorted.where(site: site).first
  end
end
