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
    validates :slug, uniqueness: { scope: :site_id }

    scope :has_section_item, -> { joins(:section_items).where("gcms_section_items.id IS NOT NULL") }

    def first_item(options = {})
      section_item = if options[:only_public] == true
                       section_items.first_level.not_archived.not_drafted.first
                     else
                       section_items.first_level.first
                     end

      section_item.item if section_item
    end

    def attributes_for_slug
      [title]
    end
  end
end
