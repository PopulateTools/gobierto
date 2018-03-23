# frozen_string_literal: true

class Issue < ApplicationRecord
  include GobiertoCommon::Sortable
  include User::Subscribable
  include GobiertoCommon::ActsAsCollectionContainer
  include GobiertoCommon::Sluggable
  include GobiertoCommon::Validatable

  belongs_to :site
  has_many :processes, class_name: 'GobiertoParticipation::Process', dependent: :restrict_with_error

  translates :name, :description

  validates :site, :name, presence: true
  validates :slug, uniqueness: { scope: :site }
  validate :uniqueness_of_name

  scope :sorted, -> { order(position: :asc, created_at: :desc) }

  def to_s
    self.name
  end

  def attributes_for_slug
    [name]
  end

  def to_url(options = {})
    url_helpers.gobierto_participation_issue_url(parameterize.merge(id: self.slug, host: app_host).merge(options))
  end

  def active_pages
    GobiertoCms::Page.pages_in_collections_and_container(self.site, self).sorted.active
  end

  def number_contributions
    contributions.size
  end

  def number_contributing_neighbours
    contributions.pluck(:user_id).uniq.size
  end

  def contributions
    GobiertoParticipation::Contribution.joins(contribution_container: :process)
                                       .where("gpart_processes.visibility_level = 1 AND
                                               gpart_contribution_containers.visibility_level = 1 AND
                                               gpart_processes.issue_id = ?", id)
  end

  private

  def uniqueness_of_name
    if name_translations.present?
      if name_translations.select{ |_, name| name.present? }.any?{ |_, name| self.class.where(site_id: self.site_id).where.not(id: self.id).with_name_translation(name).exists? }
        errors.add(:name, I18n.t('errors.messages.taken'))
      end
    end
  end
end
