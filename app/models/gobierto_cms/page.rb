require_dependency "gobierto_cms"

module GobiertoCms
  class Page < ApplicationRecord
    include User::Subscribable
    include GobiertoCommon::Searchable

    algoliasearch_gobierto do
      attribute :site_id, :updated_at, :title_en, :title_es, :title_ca, :body_en, :body_es, :body_ca
      searchableAttributes ['title_en', 'title_es', 'title_ca', 'body_en', 'body_es', 'body_ca']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    translates :title, :body, :slug
    include GobiertoCommon::LocalizedContent

    belongs_to :site

    enum visibility_level: { draft: 0, active: 1 }

    # TODO: title, body, slug validations?
    validates :site, presence: true
    validate :uniqueness_of_slug

    scope :sorted, -> { order(id: :desc) }

    def self.find_by_slug!(slug)
      if slug.present?
        self.with_slug_translation(slug).first || raise(ActiveRecord::RecordNotFound)
      end
    end

    private

    def uniqueness_of_slug
      if slug_translations.present?
        if slug_translations.any?{ |_, slug| self.class.where(site_id: self.site_id).with_slug_translation(slug).exists? }
          errors.add(:slug, I18n.t('errors.messages.taken'))
        end
      end
    end
  end
end
