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

    scope :for_pages, -> { where(item_type: "GobiertoCms::Page") }
    scope :for_archived_pages, -> { for_pages.where(item_id: Page.only_archived.pluck(:id)) }
    scope :for_draft_pages, -> { for_pages.where(item_id: Page.draft.pluck(:id)) }

    # item_type can be GobiertoCms::Section, GobiertoModule or GobiertoCms::Page,
    # but only pages can be drafted or archived
    scope :not_archived, -> { where.not(id: for_archived_pages.pluck(:id)) }
    scope :not_drafted, -> { where.not(id: for_draft_pages.pluck(:id)) }

    def item
      case item_type
        when "GobiertoModule"
          item_id.constantize
        else
          item_type.constantize.find(item_id)
      end
    end

    def not_archived?
      self.class.not_archived.include?(self)
    end

    def not_drafted?
      self.class.not_drafted.include?(self)
    end

    # TODO - try to do this with a scope. Purpose is not clear.
    def all_parents(parent_array = [])
      if parent_id != 0
        parent_array.unshift(parent)
        parent.all_parents(parent_array)
      end
      parent_array
    end

    # TODO: refactor. This method is not fully tested and breaks on edge cases.
    def hierarchy_and_children(options = {})
      items = all_parents + [self]

      if options[:only_public] == true
        items += children.not_archived.not_drafted
      else
        items += children
      end

      # TODO - this should be filtered with a scope
      items.each do |item|
        items.delete(item) unless item.not_drafted? && item.not_archived?
      end

      items
    end

    def visibility_level
      item&.visibility_level
    end

    private

    def reindex_item
      if item.is_a?(GobiertoCms::Page)
        ::GobiertoCms::Page.trigger_reindex_job(item, false)
      end
    end
  end
end
