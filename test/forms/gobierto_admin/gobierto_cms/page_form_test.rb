require "test_helper"

module GobiertoAdmin
  module GobiertoCms
    class PageFormTest < ActiveSupport::TestCase
      def valid_page_form
        @valid_page_form ||= PageForm.new(
          site_id: site.id,
          title: page.title,
          body: page.body,
          slug: page.slug,
          visibility_level: page.visibility_level
        )
      end

      def invalid_page_form
        @invalid_page_form ||= PageForm.new(
          site_id: nil,
          title: nil,
          body: nil,
          slug: nil,
          visibility_level: nil
        )
      end

      def page
        @page ||= gobierto_cms_pages(:consultation_faq)
      end

      def site
        @site ||= sites(:santander)
      end

      def test_save_with_valid_attributes
        assert valid_page_form.save
      end

      def test_error_messages_with_invalid_attributes
        invalid_page_form.save

        assert_equal 1, invalid_page_form.errors.messages[:site].size
        assert_equal 1, invalid_page_form.errors.messages[:title].size
        assert_equal 1, invalid_page_form.errors.messages[:body].size
        assert_equal 1, invalid_page_form.errors.messages[:slug].size
      end
    end
  end
end
