# frozen_string_literal: true

class Issue < ApplicationRecord
  include GobiertoCommon::Sortable
  include User::Subscribable
  include GobiertoCommon::ActsAsCollectionContainer
  include GobiertoCommon::Sluggable

  belongs_to :site
  has_many :collection_items, as: :container, class_name: 'GobiertoCommon::CollectionItem', dependent: :restrict_with_error
  
  translates :name, :description

  validates :site, :name, presence: true
  validates :slug, uniqueness: { scope: :site }
  validate :uniqueness_of_name

  scope :sorted, -> { order(position: :asc, created_at: :desc) }

  def self.alphabetically_sorted
    all.sort_by(&:name)
  end

  def to_s
    self.name
  end

  def parameterize
    { slug: slug }
  end

  def attributes_for_slug
    [name]
  end

  def active_pages(current_site)
    GobiertoCms::Page.pages_in_collections_and_container(current_site, self).active.sort_by(&:created_at).reverse
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
