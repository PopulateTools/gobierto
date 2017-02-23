require "test_helper"

module GobiertoCms
  class PageTest < ActiveSupport::TestCase

    def page
      @page ||= gobierto_cms_pages(:consultation_faq)
    end

    def test_valid
      assert page.valid?
    end
  end
end
