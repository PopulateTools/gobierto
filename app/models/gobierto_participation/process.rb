require_dependency "gobierto_participation"

module GobiertoParticipation
  class Process < ApplicationRecord
    include User::Subscribable
    include GobiertoCommon::Searchable
    include GobiertoAttachments::Attachable
    include GobiertoCommon::Collectionable

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

    def news
      news_collection ? news_collection.collection_items.map { |collection_item| collection_item.item } : []
      # TODO: write in a more efficient way. Maybe something like this:
      # GobiertoCms::Page.where(collection: news_collection)
    end

    def events
      events_collection ? events_collection.collection_items.map { |collection_item| collection_item.item } : []
      # TODO: write in a more efficient way. Maybe something like this:
      # GobiertoCalendars::Event.where(collection: events_collection)
    end

    private

    def news_collection
      GobiertoCommon::Collection.find_by(container: self, item_type: 'GobiertoCms::Page')
    end

    def events_collection
      GobiertoCommon::Collection.find_by(container: self, item_type: 'GobiertoPeople::PersonEvent')
    end

  end
end
