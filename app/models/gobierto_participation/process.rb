require_dependency "gobierto_participation"

module GobiertoParticipation
  class Process < ApplicationRecord
    include User::Subscribable
    include GobiertoCommon::Searchable
    include GobiertoAttachments::Attachable
    include GobiertoCommon::Collectionable

    PROCESS = 'p'
    GROUP   = 'g'

    algoliasearch_gobierto do
      attribute :site_id, :updated_at, :title_en, :title_es, :title_ca, :body_en, :body_es, :body_ca
      searchableAttributes ['title_en', 'title_es', 'title_ca', 'body_en', 'body_es', 'body_ca']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    def self.allowed_types
      [ PROCESS, GROUP ]
    end

    translates :title, :body, :information_text

    belongs_to :site
    belongs_to :issue
    has_many :stages, -> { order(stage_type: :asc) }, dependent: :destroy, class_name: 'GobiertoParticipation::ProcessStage'

    enum visibility_level: { draft: 0, active: 1 }

    validates :site, :title, :body, presence: true
    validates :slug, uniqueness: true

    scope :sorted,    -> { order(id: :desc) }
    scope :processes, -> { where(process_type: PROCESS) }
    scope :groups,    -> { where(process_type: GROUP)   }

    accepts_nested_attributes_for :stages

    def is_process?
      process_type == self.class::PROCESS
    end

    def is_group?
      process_type == self.class::GROUP
    end

  end
end
