# frozen_string_literal: true

require_dependency "gobierto_citizens_charters"

module GobiertoCitizensCharters
  class Service < ApplicationRecord
    acts_as_paranoid column: :archived_at

    include ActsAsParanoidAliases
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Sluggable
    include GobiertoCommon::HasVocabulary

    attr_accessor :admin_id

    belongs_to :site
    has_many :charters, dependent: :destroy
    has_many :commitments, through: :charters, class_name: "GobiertoCitizensCharters::Commitment"
    has_many :editions, through: :commitments, class_name: "GobiertoCitizensCharters::Edition"

    has_vocabulary :categories

    enum visibility_level: { draft: 0, active: 1 }

    validates :site, :title, presence: true
    validates :slug, uniqueness: { scope: :site_id }
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
