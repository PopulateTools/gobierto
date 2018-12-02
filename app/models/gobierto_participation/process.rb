# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class Process < ApplicationRecord
    acts_as_paranoid column: :archived_at

    include ActsAsParanoidAliases
    include User::Subscribable
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Searchable
    include GobiertoCommon::ActsAsCollectionContainer
    include GobiertoAttachments::Attachable
    include GobiertoCommon::HasVocabulary

    algoliasearch_gobierto do
      attribute :site_id, :updated_at, :title_en, :title_es, :title_ca, :body_en, :body_es, :body_ca
      searchableAttributes %w(title_en title_es title_ca body_en body_es body_ca)
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    translates :title, :body, :body_source, :information_text

    belongs_to :site
    has_vocabulary :issues
    has_vocabulary :scopes
    has_many :stages, -> { sorted }, dependent: :destroy, class_name: "GobiertoParticipation::ProcessStage", autosave: true
    has_many :published_stages, -> { published.sorted }, class_name: "GobiertoParticipation::ProcessStage"
    has_many :polls
    has_many :contribution_containers, dependent: :destroy, class_name: "GobiertoParticipation::ContributionContainer"

    enum visibility_level: { draft: 0, active: 1 }
    enum process_type: { process: 0, group_process: 1 }

    validates :site, presence: true
    validates :slug, uniqueness: { scope: :site_id }

    scope :sorted, -> { order(id: :desc) }

    after_create :create_collections
    after_destroy :delete_collections
    after_restore :set_slug

    alias public? active?

    def to_s
      title
    end

    def active_stage?(stage_type)
      stages.exists?(stage_type: stage_type)
    end

    def news_collection
      find_collection_of_items("GobiertoCms::News")
    end

    def events_collection
      find_collection_of_items("GobiertoCalendars::Event")
    end

    def attachments_collection
      find_collection_of_items("GobiertoAttachments::Attachment")
    end

    def events
      ProcessCollectionDecorator.new(site.events).in_process(self)
    end

    def attachments
      ProcessCollectionDecorator.new(site.attachments).in_process(self)
    end

    def news
      ProcessCollectionDecorator.new(site.pages, item_type: "GobiertoCms::News").in_process(self)
    end

    def current_stage
      published_stages.find_by(active: true)
    end

    def next_stage
      if published_stages.upcoming
        published_stages.upcoming.order(starts: :asc).first
      else
        GobiertoParticipation::ProcessStage.none
      end
    end

    def showcase_stage
      current_stage || next_stage || published_stages.order(ends: :asc).last || published_stages.last
    end

    def open?
      return false if starts.present? && starts > Time.zone.now
      return false if ends.present? && ends < Time.zone.now
      true
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

    def resource_path
      url_helpers.gobierto_participation_process_url(id: slug, host: site.domain)
    end

    def to_url(options = {})
      if draft? && options[:preview] && options[:admin]
        options[:preview_token] = options[:admin].preview_token
      end
      url_helpers.gobierto_participation_process_url(
        options.except(:preview, :admin).merge(id: slug, host: site.domain)
      )
    end

    private

    def create_collections
      # Events
      site.collections.create! container: self, item_type: "GobiertoCalendars::Event", slug: "calendar-#{slug}", title: title
      # Attachments
      site.collections.create! container: self, item_type: "GobiertoAttachments::Attachment", slug: "attachment-#{slug}", title: title
      # News
      site.collections.create! container: self, item_type: "GobiertoCms::News", slug: "news-#{slug}", title: title
    end

    def delete_collections
      # Events
      events_collection = site.collections.find_by(container: self, item_type: "GobiertoCalendars::Event")
      if events_collection
        site.events.where(collection: events_collection).destroy_all
        events_collection.destroy
      end

      # Attachments
      attachments_collection = site.collections.find_by(container: self, item_type: "GobiertoAttachments::Attachment")
      if attachments_collection
        site.attachments.where(collection: attachments_collection).destroy_all
        attachments_collection.destroy
      end

      # News
      news_collection =  site.collections.find_by(container: self, item_type: "GobiertoCms::News")
      if news_collection
        site.pages.where(collection: news_collection).destroy_all
        news_collection.destroy
      end
    end

    def attributes_for_slug
      [title]
    end

    def find_collection_of_items(item_type)
      GobiertoCommon::Collection.find_by(container: self, item_type: item_type)
    end
  end
end
