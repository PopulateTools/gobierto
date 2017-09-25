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
    has_many :stages, -> { order(stage_type: :asc) }, dependent: :destroy, class_name: 'GobiertoParticipation::ProcessStage', autosave: true
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
      ids = GobiertoParticipation::Process.select(&:open?).map(&:id)
      where(id: ids)
    end

    def to_s
      title
    end

    def polls_stage?
      stages.exists?(stage_type: ProcessStage.stage_types[:polls])
    end

    def information_stage?
      stages.exists?(stage_type: ProcessStage.stage_types[:information])
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
      if stages.active.any?
        active_and_open_stages = stages.active.open
        active_and_open_stages.order(ends: :asc).last
      end
    end

    def open?
      if starts.present? && ends.present?
        Time.zone.now.between?(starts, ends)
      else
        true
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
