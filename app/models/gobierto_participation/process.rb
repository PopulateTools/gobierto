# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class Process < ApplicationRecord
    acts_as_paranoid column: :archived_at

    include ActsAsParanoidAliases
    include User::Subscribable
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Searchable
    include GobiertoCommon::ActsAsCollectionContainer
    include GobiertoAttachments::Attachable

    algoliasearch_gobierto do
      attribute :site_id, :updated_at, :title_en, :title_es, :title_ca, :body_en, :body_es, :body_ca
      searchableAttributes %w(title_en title_es title_ca body_en body_es body_ca)
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    translates :title, :body, :information_text

    belongs_to :site
    belongs_to :issue
    belongs_to :scope, class_name: "GobiertoCommon::Scope"
    has_many :stages, -> { sorted }, dependent: :delete_all, class_name: "GobiertoParticipation::ProcessStage", autosave: true
    has_many :published_stages, -> { published.sorted }, class_name: "GobiertoParticipation::ProcessStage"
    has_many :polls
    has_many :contribution_containers, dependent: :destroy, class_name: "GobiertoParticipation::ContributionContainer"

    enum visibility_level: { draft: 0, active: 1 }
    enum process_type: { process: 0, group_process: 1 }

    validates :site, presence: true
    validates :slug, uniqueness: { scope: :site }

    scope :sorted, -> { order(id: :desc) }

    after_create :create_collections
    after_restore :set_slug

    def to_s
      title
    end

    def information_stage?
      active_stage?(ProcessStage.stage_types[:information])
    end

    def polls_stage?
      active_stage?(ProcessStage.stage_types[:polls])
    end

    def contributions_stage?
      active_stage?(ProcessStage.stage_types[:contributions])
    end

    def results_stage?
      active_stage?(ProcessStage.stage_types[:results])
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
      url_helpers.gobierto_participation_process_url({ id: slug }.merge(host: site.domain))
    end

    def to_url(options = {})
      url_helpers.gobierto_participation_process_url(parameterize.merge(id: self.slug, host: app_host).merge(options))
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

    def attributes_for_slug
      [title]
    end

    def find_collection_of_items(item_type)
      GobiertoCommon::Collection.find_by(container: self, item_type: item_type)
    end
  end
end
