# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class ProcessStage < ApplicationRecord
    include GobiertoCommon::Sortable

    before_destroy :check_stage_active

    belongs_to :process

    translates :title, :description, :cta_text, :cta_description

    enum stage_type: { information: 0, meetings: 1, polls: 2, ideas: 3, results: 4 }
    enum visibility_level: { draft: 0, active: 1 }

    validates :slug, uniqueness: { scope: [:process_id] }
    validates :title, :starts, :ends, presence: true, if: -> { active? }
    validate :cta_text_maximum_length
    validates :stage_type, presence: true
    validates :stage_type, inclusion: { in: stage_types }
    validates :stage_type, uniqueness: { scope: [:process_id] }

    scope :sorted, -> { order(position: :asc, created_at: :desc) }
    scope :open, -> { where("starts <= ? AND ends >= ?", Time.zone.now, Time.zone.now) }
    scope :active, -> { where(active: true) }
    scope :active_visibility, -> { where(visibility_level: "active") }
    scope :upcoming, -> { where("starts > ?", Time.zone.now) }
    scope :by_site, ->(site) { joins(process: :site).where("sites.id = ?
                                                            AND gpart_polls.visibility_level = 1 AND gpart_polls.ends_at >= ?",
                                                            site.id, Time.zone.now) }

    def open?
      date = Time.zone.now.to_date
      starts <= date && ends >= date
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
        url_helpers.gobierto_participation_process_information_path(process.slug)
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

    def check_stage_active
      return true unless active?
      false
      throw(:abort)
    end

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
