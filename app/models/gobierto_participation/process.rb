require_dependency "gobierto_participation"

module GobiertoParticipation
  class Process < ApplicationRecord
    include User::Subscribable
    include GobiertoCommon::Searchable
    include GobiertoAttachments::Attachable
    include GobiertoCommon::ActsAsCollectionContainer

    algoliasearch_gobierto do
      attribute :site_id, :updated_at, :title_en, :title_es, :title_ca, :body_en, :body_es, :body_ca
      searchableAttributes ['title_en', 'title_es', 'title_ca', 'body_en', 'body_es', 'body_ca']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    translates :title, :body, :information_text

    belongs_to :site
    belongs_to :issue
    has_many :stages, -> { order(stage_type: :asc) }, dependent: :destroy, class_name: 'GobiertoParticipation::ProcessStage'

    enum visibility_level: { draft: 0, active: 1 }
    enum process_type: { process: 0, group_process: 1 }

    validates :site, :title, :body, presence: true
    validates :slug, uniqueness: { scope: :site }

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

    def extend_news
      news = self.news_in_collections.sort_by_updated_at(5)
      news.merge(issue.news_in_collections) if issue
      news
    end

    def extend_events
      news = self.events_in_collections.sort_by_updated_at(5)
      news.merge(issue.events_in_collections) if issue
      news
    end

    def extend_attachments
      news = self.attachments_in_collections.sort_by_updated_at(5)
      news.merge(issue.attachments_in_collections) if issue
      news
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
      if open?
        process_stages = stages.where("starts >= ? AND ends <= ?", Time.zone.now, Time.zone.now)
        process_stages.first.to_s
      end
    end

    def open?
      if stages.any?
        Time.zone.now.between?(stages.last.starts, stages.last.ends)
      else
        false
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

  end
end
