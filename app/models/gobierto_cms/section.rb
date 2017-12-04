# frozen_string_literal: true

require_dependency "gobierto_cms"

module GobiertoCms
  class Section < ApplicationRecord
    include GobiertoCommon::Sortable
    include GobiertoCommon::Sluggable

    belongs_to :site
    has_many :section_items, dependent: :destroy, class_name: "GobiertoCms::SectionItem"

    translates :title

    validates :site, :title, presence: true
    validates :slug, uniqueness: { scope: :site }

    scope :has_section_item, -> { joins(:section_items).where("gcms_section_items.id IS NOT NULL") }

    def first_item
      if section_item = section_items.first_level.first
        section_item.item
      end
    end

    def attributes_for_slug
      [title]
    end
  end
end
