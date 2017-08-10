require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    class CollectionFormTest < ActiveSupport::TestCase
      def valid_form(file = nil)
        @valid_form ||= CollectionForm.new(
          site_id: site.id,
          title_translations: { 'en' => 'Collection', 'es' => 'Colección' },
          slug: 'collection',
          container_global_id: container.to_global_id,
          item_type: item_type
        )
      end

      def invalid_form(file = nil)
        @invalid_form ||= CollectionForm.new
      end

      def site
        @sites ||= sites(:madrid)
      end

      def container
        @container ||= gobierto_people_people(:richard)
      end

      def item_type
        'GobiertoCms::Page'
      end

      def test_save_with_valid_attributes
        assert valid_form.save
      end

      def test_save_with_invalid_attributes
        invalid_form.save

        assert_equal 1, invalid_form.errors.messages[:site].size
      end
    end
  end
end
