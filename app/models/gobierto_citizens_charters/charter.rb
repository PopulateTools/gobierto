# frozen_string_literal: true

require_dependency "gobierto_citizens_charters"

module GobiertoCitizensCharters
  class Charter < ApplicationRecord
    acts_as_paranoid column: :archived_at

    include ActsAsParanoidAliases
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Sluggable

    belongs_to :service, -> { with_archived }
    has_many :commitments, dependent: :destroy
    has_many :editions, through: :commitments, class_name: "GobiertoCitizensCharters::Edition"

    enum visibility_level: { draft: 0, active: 1 }

    validates :slug, uniqueness: { scope: :service_id }
    translates :title
    delegate :category, to: :service

    after_restore :set_slug

    def parameterize
      { slug: slug }
    end

    def attributes_for_slug
      [title]
    end

    def to_s
      title
    end

    def belongs_to_archived?
      service.archived?
    end
  end
end
