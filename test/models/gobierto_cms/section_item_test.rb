# frozen_string_literal: true

require "test_helper"

module GobiertoCms
  class SectionItemTest < ActiveSupport::TestCase

    def section_items
      SectionItem.unscoped
    end

    def not_archived_items
      section_items.not_archived
    end

    def not_drafted_items
      section_items.not_drafted
    end

    def page_section_item
      gobierto_cms_section_items(:santander_cms_p0_section_item)
    end
    alias section_item page_section_item

    def section_section_item
      gobierto_cms_section_items(:santander_navigation_budgets_item)
    end

    def module_section_item
      gobierto_cms_section_items(:santander_navigation_section_item)
    end

    def test_valid
      assert section_item.valid?
    end

    def test_not_archived_scope
      assert not_archived_items.include?(page_section_item)
      assert not_archived_items.include?(section_section_item)
      assert not_archived_items.include?(module_section_item)

      page_section_item.item.archive

      refute not_archived_items.include?(page_section_item)
      assert not_archived_items.include?(section_section_item)
      assert not_archived_items.include?(module_section_item)
    end

    def test_not_drafted_scope
      assert not_drafted_items.include?(page_section_item)
      assert not_drafted_items.include?(section_section_item)
      assert not_drafted_items.include?(module_section_item)

      page_section_item.item.draft!

      refute not_drafted_items.include?(page_section_item)
      assert not_drafted_items.include?(section_section_item)
      assert not_drafted_items.include?(module_section_item)
    end

  end
end
