require_dependency "gobierto_participation"

module GobiertoParticipation
  class ProcessStage < ApplicationRecord
    belongs_to :process

    translates :title, :slug

    validate :uniqueness_of_slug

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
        if slug_translations.select{ |_, slug| slug.present? }.any?{ |_, slug| self.class.where(process_id: self.process_id).where.not(id: self.id).with_slug_translation(slug).exists? }
          errors.add(:slug, I18n.t('errors.messages.taken'))
        end
      end
    end
  end
end
