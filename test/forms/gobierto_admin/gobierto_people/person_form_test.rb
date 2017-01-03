require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PersonFormTest < ActiveSupport::TestCase
      def valid_person_form
        @valid_person_form ||= PersonForm.new(
          admin_id: admin.id,
          site_id: site.id,
          name: person.name,
          charge: person.charge,
          bio: person.bio,
          bio_url: person.bio_url,
          visibility_level: person.visibility_level
        )
      end

      def invalid_person_form
        @invalid_person_form ||= PersonForm.new(
          admin_id: nil,
          site_id: nil,
          name: nil
        )
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def admin
        @admin ||= gobierto_admin_admins(:tony)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_save_with_valid_attributes
        assert valid_person_form.save
      end

      def test_error_messages_with_invalid_attributes
        invalid_person_form.save

        assert_equal 1, invalid_person_form.errors.messages[:admin].size
        assert_equal 1, invalid_person_form.errors.messages[:site].size
        assert_equal 1, invalid_person_form.errors.messages[:name].size
      end
    end
  end
end
