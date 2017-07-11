require_dependency "gobierto_participation"

module GobiertoParticipation
  class Issue < ApplicationRecord

    belongs_to :site

    translates :name, :slug

    validates :site, :name, :slug, presence: true
    validate :uniqueness_of_slug
    validate :uniqueness_of_name

    scope :sorted, -> { order(id: :desc) }

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

    def uniqueness_of_name
      if name_translations.present?
        if name_translations.select{ |_, name| name.present? }.any?{ |_, name| self.class.where(site_id: self.site_id).where.not(id: self.id).with_name_translation(name).exists? }
          errors.add(:name, I18n.t('errors.messages.taken'))
        end
      end
    end
  end
end
