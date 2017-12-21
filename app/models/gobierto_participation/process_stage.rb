# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class ProcessStage < ApplicationRecord
    include GobiertoCommon::Sortable
    include GobiertoCommon::Sluggable

    before_destroy :check_stage_active

    belongs_to :process

    translates :title, :description, :cta_text, :cta_description, :menu

    enum stage_type: { information: 0, meetings: 1, polls: 2, ideas: 3, results: 4 }
    enum visibility_level: { draft: 0, published: 1 }

    validates :slug, uniqueness: { scope: [:process_id] }
    validates :title, :description, :cta_text, :cta_description, :starts, :ends, :menu, presence: true, if: -> { published? }
    validate :cta_text_maximum_length
    validate :cta_description_maximum_length
    validate :menu_maximum_length
    validates :stage_type, presence: true
    validates :stage_type, inclusion: { in: stage_types }

    scope :sorted, -> { order(position: :asc, id: :asc) }
    scope :active, -> { where(active: true) }
    scope :published, -> { where(visibility_level: "published") }
    scope :by_site, ->(site) { joins(process: :site).where("sites.id = ?
                                                            AND gpart_polls.visibility_level = 1 AND gpart_polls.ends_at >= ?",
                                                            site.id, Time.zone.now) }

    def self.upcoming
      unless published.select(&:upcoming?).empty?
        stages_id = published.select(&:upcoming?).pluck(:id)
        GobiertoParticipation::ProcessStage.where(id: stages_id)
      else
        GobiertoParticipation::ProcessStage.none
      end
    end

    def published?
      visibility_level == "published"
    end

    def current_stage
      process.current_stage
    end

    def active?
      active
    end

    def past?
      # ends && (ends < Time.zone.now)
      if position < current_stage.position
        true
      elsif id < current_stage.id
        true
      else
        false
      end
    end

    def upcoming?
      if current_stage
        if position > current_stage.position
          true
        elsif id > current_stage.id
          true
        else
          false
        end
      else
        false
      end
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

    def menu_maximum_length
      if menu_translations
        menu_translations.each do |menu_translation|
          errors.add(:menu, "Is too long") if menu_translation.length > 50
        end
      end
    end

    def cta_description_maximum_length
      if cta_description_translations
        cta_description_translations.each do |cta_description_translation|
          errors.add(:cta_description, "Is too long") if cta_description_translation.length > 50
        end
      end
    end

    def url_helpers
      Rails.application.routes.url_helpers
    end
  end
end
