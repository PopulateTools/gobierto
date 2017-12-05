# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_attachments/attachable_test"

module GobiertoCms
  class PageTest < ActiveSupport::TestCase
    include GobiertoAttachments::AttachableTest

    def page
      @page ||= gobierto_cms_pages(:consultation_faq)
    end
    alias attachable_with_attachment page
    alias collectionable_object page

    def attachable_without_attachment
      @attachable_without_attachment ||= gobierto_cms_pages(:privacy)
    end

    def test_valid
      assert page.valid?
    end

    def test_searchable_body
      assert page.searchable_body.include?("This is the body of the page")
      assert page.searchable_body.include?("Cuerpo página consultas")
    end

    def test_searchable_body_on_empty_page
      new_page = GobiertoCms::Page.new
      assert_equal "", new_page.searchable_body
      assert_equal "", new_page.searchable_body
    end
  end
end
