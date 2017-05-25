# frozen_string_literal: true

require 'test_helper'

module GobiertoCms
  class PageTest < ActiveSupport::TestCase
    def page
      @page ||= gobierto_cms_pages(:consultation_faq)
    end

    def test_valid
      assert page.valid?
    end

    def test_find_by_slug
      assert_nil GobiertoCms::Page.find_by! slug: nil
      assert_nil GobiertoCms::Page.find_by! slug: ''
      assert_raises(ActiveRecord::RecordNotFound) do
        GobiertoCms::Page.find_by! slug: 'foo'
      end

      assert_equal page, GobiertoCms::Page.find_by!(slug: page.slug_es)
      assert_equal page, GobiertoCms::Page.find_by!(slug: page.slug_en)
    end
  end
end
