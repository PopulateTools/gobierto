# frozen_string_literal: true

module GobiertoCommon
  class Scope < ApplicationRecord
    include GobiertoCommon::Sortable
    include GobiertoCommon::Sluggable
    include GobiertoCommon::ActsAsCollectionContainer
    include User::Subscribable
    include GobiertoCommon::Validatable

    translates :name, :description

    belongs_to :site
    has_many :processes, class_name: "GobiertoParticipation::Process", dependent: :restrict_with_error

    validates :site, :name, presence: true
    validates :slug, uniqueness: { scope: :site }

    scope :sorted, -> { order(position: :asc, created_at: :desc) }

    def parameterize
      { slug: slug }
    end

    def attributes_for_slug
      [name]
    end

    def active_pages
      GobiertoCms::Page.pages_in_collections_and_container(site, self).sorted.active
    end
  end
end
