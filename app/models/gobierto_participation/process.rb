# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class Process < ApplicationRecord

    include User::Subscribable
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Searchable
    include GobiertoCommon::ActsAsCollectionContainer
    include GobiertoAttachments::Attachable

    algoliasearch_gobierto do
      attribute :site_id, :updated_at, :title_en, :title_es, :title_ca, :body_en, :body_es, :body_ca
      searchableAttributes ['title_en', 'title_es', 'title_ca', 'body_en', 'body_es', 'body_ca']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    translates :title, :body, :information_text

    belongs_to :site
    belongs_to :issue
    belongs_to :scope, class_name: 'GobiertoCommon::Scope'
    has_many :stages, -> { sorted }, dependent: :destroy, class_name: 'GobiertoParticipation::ProcessStage', autosave: true
    has_many :active_stages, -> { active.sorted }, class_name: 'GobiertoParticipation::ProcessStage'
    has_many :polls
    has_many :contribution_containers, dependent: :destroy, class_name: "GobiertoParticipation::ContributionContainer"

    enum visibility_level: { draft: 0, active: 1 }
    enum process_type: { process: 0, group_process: 1 }

    validates :site, :title, presence: true
    validates :slug, uniqueness: { scope: :site }
    validates_associated :stages, message: I18n.t('activerecord.messages.gobierto_participation/process.are_not_valid')

    scope :sorted, -> { order(id: :desc) }

    accepts_nested_attributes_for :stages

    after_create :create_collections

    def self.open
      ids = GobiertoParticipation::Process.select(&:open?).pluck(:id)
      where(id: ids)
    end

    def to_s
      title
    end

    def information_stage?
      active_stage?(ProcessStage.stage_types[:information])
    end

    def polls_stage?
      active_stage?(ProcessStage.stage_types[:polls])
    end

    def ideas_stage?
      active_stage?(ProcessStage.stage_types[:ideas])
    end

    def results_stage?
      active_stage?(ProcessStage.stage_types[:results])
    end

    def active_stage?(stage_type)
      stages.exists?(stage_type: stage_type)
    end

    def pages_collection
      GobiertoCommon::Collection.find_by(container: self, item_type: 'GobiertoCms::Page')
    end

    def events_collection
      GobiertoCommon::Collection.find_by(container: self, item_type: 'GobiertoCalendars::Event')
    end

    def attachments_collection
      GobiertoCommon::Collection.find_by(container: self, item_type: 'GobiertoAttachments::Attachment')
    end

    def current_stage
      active_stages.open.order(ends: :asc).last
    end

    def next_stage
      active_stages.upcoming.order(starts: :asc).first
    end

    def showcase_stage
      current_stage || next_stage ||  active_stages.order(ends: :asc).last || active_stages.last
    end

    def open?
      return false if starts.present? && starts > Time.zone.now
      return false if ends.present? && ends < Time.zone.now
      return true
    end

    def last_activity
      Activity.where(subject: self).last
    end

    def last_activity_at
      if Activity.where(subject: self).last
        Activity.where(subject: self).last.created_at
      else
        updated_at
      end
    end

    private

    def create_collections
      # Events
      site.collections.create! container: self,  item_type: 'GobiertoCalendars::Event', slug: "calendar-#{self.slug}", title: self.title
      # Attachments
      site.collections.create! container: self,  item_type: 'GobiertoAttachments::Attachment', slug: "attachment-#{self.slug}", title: self.title
      # News / Pages
      site.collections.create! container: self,  item_type: 'GobiertoCms::Page', slug: "news-#{self.slug}", title: self.title
    end

    def attributes_for_slug
      [ title ]
    end

  end
end
