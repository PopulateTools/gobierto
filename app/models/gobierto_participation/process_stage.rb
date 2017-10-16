require_dependency "gobierto_participation"

module GobiertoParticipation
  class ProcessStage < ApplicationRecord

    belongs_to :process

    translates :title, :description, :cta_text

    enum stage_type: { information: 0, meetings: 1, polls: 2, ideas: 3, results: 4 }

    validates :slug, uniqueness: { scope: [:process_id] }
    validates :title, :starts, :ends, presence: true, if: -> { active? }
    validate :cta_text_maximum_length
    validates :stage_type, presence: true
    validates :stage_type, inclusion: { in: stage_types }
    validates :stage_type, uniqueness: { scope: [:process_id] }

    scope :sorted,   -> { order(stage_type: :asc) }
    scope :open,     -> { where('starts <= ? AND ends >= ?', Time.zone.now, Time.zone.now) }
    scope :active,   -> { where(active: true) }
    scope :upcoming, -> { where('starts > ?', Time.zone.now) }

    def open?
      Time.zone.now.between?(starts, ends)
    end

    def active?
      active
    end

    def past?
      ends && (ends < Time.zone.now)
    end

    def upcoming?
      starts && (starts > Time.zone.now)
    end

    def current?
      self == process.current_stage
    end

    def to_s
      self.title
    end

    def process_stage_path
      if information?
        url_helpers.gobierto_participation_process_process_information_path(process.slug)
      elsif meetings?
        url_helpers.gobierto_participation_process_events_path(process.slug)
      elsif polls?
        url_helpers.gobierto_participation_process_polls_path(process.slug)
      elsif ideas?
        '#' # TODO
      elsif results?
        '#' # TODO
      end
    end

    private

    def cta_text_maximum_length
      if cta_text_translations
        cta_text_translations.each do |cta_text_translation|
          errors.add(:cta_text, "Is too long") if cta_text_translation.length > 32
        end
      end
    end

    def url_helpers
      Rails.application.routes.url_helpers
    end

  end
end
