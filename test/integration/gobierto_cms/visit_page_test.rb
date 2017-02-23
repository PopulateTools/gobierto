require "test_helper"

module GobiertoCms
  class VisitPageTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_cms_page_path(cms_page)
    end

    def site
      @site ||= sites(:madrid)
    end

    def cms_page
      @cms_page ||= gobierto_cms_pages(:consultation_faq)
    end

    def test_visit_page
      with_current_site(site) do
        visit @path

        assert has_selector?("h1", text: cms_page.title)
        assert has_content?(cms_page.body)
      end
    end
  end
end
