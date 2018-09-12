# frozen_string_literal: true

require_dependency "gobierto_citizens_charters"

module GobiertoCitizensCharters
  class Commitment < ApplicationRecord
    acts_as_paranoid column: :archived_at

    include ActsAsParanoidAliases
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Sluggable

    belongs_to :charter
    has_many :editions, dependent: :destroy

    enum visibility_level: { draft: 0, active: 1 }

    validates :slug, uniqueness: { scope: :charter }
    translates :title

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
  end
end
