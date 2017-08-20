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
  end
end
