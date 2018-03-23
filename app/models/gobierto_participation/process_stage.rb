# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class ProcessStage < ApplicationRecord
    include GobiertoCommon::Sortable
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Validatable

    before_destroy :check_stage_active

    belongs_to :process
    has_one :process_stage_page, class_name: "GobiertoParticipation::ProcessStagePage", dependent: :destroy

    translates :title, :description, :cta_text, :cta_description, :menu

    enum stage_type: { information: 0, agenda: 1, polls: 2, contributions: 3, documents: 4,
                       pages: 5, results: 6 }
    enum visibility_level: { draft: 0, published: 1 }

    validates :slug, uniqueness: { scope: [:process_id] }
    validates :title, :description, :menu, presence: true, if: -> { published? }
    validates :cta_text, :cta_description, :starts, :ends, presence: true, if: -> { published? && process.process? }
    validate :cta_text_maximum_length, if: -> { published? && process.process? }
    validate :cta_description_maximum_length, if: -> { published? && process.process? }
    validate :menu_maximum_length
    validates :stage_type, presence: true

    scope :sorted, -> { order(position: :asc, id: :asc) }
    scope :active, -> { where(active: true) }
    # information and results stages are only visible if they also have an associated page
    scope :published, -> { where("gpart_process_stages.visibility_level=1 AND
                                  (gpart_process_stages.stage_type NOT IN (0,6) OR
                                  (gpart_process_stages.stage_type IN (0,6) AND
                                  gpart_process_stages.id IN (SELECT gpart_process_stage_pages.process_stage_id
                                  FROM gpart_process_stage_pages)))") }
    scope :by_site, ->(site) { joins(process: :site).where("sites.id = ?
                                                            AND gpart_polls.visibility_level = 1 AND gpart_polls.ends_at >= ?",
                                                            site.id, Time.zone.now) }

    def self.upcoming
      if published.select(&:upcoming?).any?
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
      elsif agenda?
        url_helpers.gobierto_participation_process_events_path(process.slug)
      elsif polls?
        url_helpers.gobierto_participation_process_polls_path(process.slug)
      elsif ideas?
        '#' # TODO
      elsif results?
        '#' # TODO
      end
    end

    def attributes_for_slug
      [title]
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
