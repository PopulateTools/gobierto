require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PoliticalGroupFormTest < ActiveSupport::TestCase
      def valid_political_group_form
        @valid_political_group_form ||= PoliticalGroupForm.new(
          admin_id: admin.id,
          site_id: site.id,
          name: political_group.name
        )
      end

      def invalid_political_group_form
        @invalid_political_group_form ||= PoliticalGroupForm.new(
          admin_id: nil,
          site_id: nil,
          name: nil
        )
      end

      def political_group
        @political_group ||= gobierto_people_political_groups(:marvel)
      end

      def admin
        @admin ||= gobierto_admin_admins(:tony)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_save_with_valid_attributes
        assert valid_political_group_form.save
      end

      def test_error_messages_with_invalid_attributes
        invalid_political_group_form.save

        assert_equal 1, invalid_political_group_form.errors.messages[:admin].size
        assert_equal 1, invalid_political_group_form.errors.messages[:site].size
        assert_equal 1, invalid_political_group_form.errors.messages[:name].size
      end
    end
  end
end
