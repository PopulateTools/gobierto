# frozen_string_literal: true

require_dependency "gobierto_cms"

module GobiertoCms
  class SectionItem < ApplicationRecord
    belongs_to :item, polymorphic: true
    belongs_to :section
    belongs_to :parent, class_name: "GobiertoCms::SectionItem", foreign_key: "parent_id"
    has_many :children, dependent: :destroy, class_name: "GobiertoCms::SectionItem", foreign_key: "parent_id"

    after_commit :reindex_page, on: [:create, :update]

    validates :item_id, :item_type, :position, :parent_id, :section_id, :level, presence: true

    scope :without_parent, -> { where(parent_id: 0) }
    scope :sorted, -> { order(position: :asc) }

    def all_parents(parent_array = [])
      if parent_id != 0
        parent_array.unshift(parent)
        parent.all_parents(parent_array)
      end
      parent_array
    end

    def hierarchy_and_children
      hierarchy = all_parents
      hierarchy.push(self)
      children.each do |child|
        hierarchy.push(child)
      end

      hierarchy
    end

    private

    def reindex_page
      if item.class_name == "GobiertoCms::Page"
        ::GobiertoCms::Page.trigger_reindex_job(item, false)
      end
    end
  end
end
