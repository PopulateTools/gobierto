# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PersonFormTest < ActiveSupport::TestCase
      def valid_person_form
        @valid_person_form ||= PersonForm.new(
          admin_id: admin.id,
          site_id: site.id,
          name: person.name,
          charge_translations: { I18n.locale => person.charge },
          bio_translations: { I18n.locale => person.bio },
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

      def uploaded_file
        @uploaded_file ||= begin
                             tmp_file = Tempfile.new
                             tmp_file.binmode
                             tmp_file.write("Test content")
                             ActionDispatch::Http::UploadedFile.new(tempfile: tmp_file,
                                                                    original_filename: "file.pdf")
                           end
      end

      def test_save_with_valid_attributes
        assert valid_person_form.save
        assert valid_person_form.person.google_calendar_token.present?
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

      def test_content_block_records_are_assigned_after_site_id
        person_params = { name: person.name, content_block_records_attributes: { "0" => { attachment_file: uploaded_file } } }

        GobiertoCommon::FileUploadService.any_instance.stubs(:call).returns("http://host.com/file.pdf")

        person_form = PersonForm.new(person_params.merge(id: person.id, admin_id: admin.id, site_id: site.id))

        assert person_form.valid?
      end
    end
  end
end
