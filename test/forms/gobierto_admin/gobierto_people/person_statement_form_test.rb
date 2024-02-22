# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PersonStatementFormTest < ActiveSupport::TestCase
      def valid_person_statement_form
        @valid_person_statement_form ||= PersonStatementForm.new(
          person_id: person.id,
          site_id: site.id,
          title_translations: { I18n.locale => person_statement.title },
          published_on: person_statement.published_on,
          attachment_url: person_statement.attachment_url,
          attachment_size: person_statement.attachment_size,
          visibility_level: person.visibility_level
        )
      end

      def invalid_person_statement_form
        @invalid_person_statement_form ||= PersonStatementForm.new(
          person_id: person.id,
          title_translations: {},
          published_on: nil
        )
      end

      def person_statement
        @person_statement ||= gobierto_people_person_statements(:richard_current)
      end

      def person
        @person ||= person_statement.person
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
        assert valid_person_statement_form.save
      end

      def test_error_messages_with_invalid_attributes
        invalid_person_statement_form.save

        assert_equal 1, invalid_person_statement_form.errors.messages[:title_translations].size
      end

      def test_published_on
        assert_equal(
          person_statement.published_on.strftime("%Y-%m-%d"),
          valid_person_statement_form.published_on.strftime("%Y-%m-%d")
        )
      end

      def test_content_block_records_are_assigned_after_site_id
        person_statement_params = {
          title_translations: { I18n.locale => person_statement.title },
          published_on: person_statement.published_on,
          content_block_records_attributes: { "0" => { attachment_file: uploaded_file } }
        }

        GobiertoCommon::FileUploadService.any_instance.stubs(:call).returns("http://host.com/file.pdf")

        person_statement_form = PersonStatementForm.new(person_statement_params.merge(person_id: person.id, admin_id: admin.id, site_id: site.id))

        assert person_statement_form.valid?
      end
    end
  end
end
