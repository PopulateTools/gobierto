require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PersonFormTest < ActiveSupport::TestCase
      def valid_person_form
        @valid_person_form ||= PersonForm.new(
          admin_id: admin.id,
          site_id: site.id,
          name: person.name,
          charge_translations: {I18n.locale => person.charge},
          bio_translations: {I18n.locale => person.bio},
          bio_url: person.bio_url,
          visibility_level: person.visibility_level,
          category: person.category,
          party: person.party,
          political_group_id: person.political_group_id
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

      def test_party
        assert_equal person.party, valid_person_form.party
      end

      def test_party_for_executive_category
        valid_person_form.category = "executive"

        assert_nil valid_person_form.party
      end

      def test_political_group_id
        assert_equal person.political_group_id, valid_person_form.political_group_id
      end

      def test_political_group_id_for_executive_category
        valid_person_form.category = "executive"

        assert_nil valid_person_form.political_group_id
      end
    end
  end
end
