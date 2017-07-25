require_dependency "gobierto_cms"

module GobiertoCms
  class Page < ApplicationRecord
    include User::Subscribable
    include GobiertoCommon::Searchable
    include GobiertoAttachments::Attachable
    include GobiertoCommon::Collectionable

    algoliasearch_gobierto do
      attribute :site_id, :updated_at, :title_en, :title_es, :title_ca, :body_en, :body_es, :body_ca
      searchableAttributes ['title_en', 'title_es', 'title_ca', 'body_en', 'body_es', 'body_ca']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    translates :title, :body, :slug

    belongs_to :site
    has_many :collection_items, as: :item

    enum visibility_level: { draft: 0, active: 1 }

    validates :site, :title, :body, :slug, presence: true
    validate :uniqueness_of_slug

    scope :sorted, -> { order(id: :desc) }
    scope :sort_by_updated_at, -> { order(updated_at: :desc) }

    def self.find_by_slug!(slug)
      if slug.present?
        I18n.available_locales.each do |locale|
          if p = self.with_slug_translation(slug, locale).first
            return p
          end
        end
        raise(ActiveRecord::RecordNotFound)
      end
    end

    private

    def uniqueness_of_slug
      if slug_translations.present?
        if slug_translations.select{ |_, slug| slug.present? }.any?{ |_, slug| self.class.where(site_id: self.site_id).where.not(id: self.id).with_slug_translation(slug).exists? }
          errors.add(:slug, I18n.t('errors.messages.taken'))
        end
      end
    end
  end
end
