# frozen_string_literal: true

require_dependency "gobierto_cms"

module GobiertoCms
  class SectionItem < ApplicationRecord
    belongs_to :item, polymorphic: true
    belongs_to :section
    belongs_to :parent, class_name: "GobiertoCms::SectionItem", foreign_key: "parent_id"
    has_many :children, -> { sorted }, dependent: :destroy, class_name: "GobiertoCms::SectionItem", foreign_key: "parent_id"

    after_commit :reindex_item, on: [:create, :update]

    validates :item_id, :item_type, :position, :parent_id, :section_id, :level, presence: true

    scope :without_parent, -> { where(parent_id: 0) }
    scope :sorted, -> { order(position: :asc) }
    scope :first_level, -> { without_parent.sorted }

    def item
      case item_type
        when "GobiertoModule"
          item_id.constantize
        else
          item_type.constantize.find(item_id)
      end
    end

    def all_parents(parent_array = [])
      if parent_id != 0
        parent_array.unshift(parent)
        parent.all_parents(parent_array)
      end
      parent_array
    end

    def hierarchy_and_children
      all_parents + [self] + children
    end

    private

    def reindex_item
      if item.is_a?(GobiertoCms::Page)
        ::GobiertoCms::Page.trigger_reindex_job(item, false)
      end
    end
  end
end
