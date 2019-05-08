# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module ContentBlockRecords
      class ContentBlockRecordCreateTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = edit_admin_people_person_path(gobierto_people_people(:richard))
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def site
          @site ||= sites(:madrid)
        end

        def accomplishments_content_block
          "div[data-title='Accomplishments']"
        end

        def test_content_block_record_create
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                # Create new record with attachment

                within accomplishments_content_block do
                  find("a[data-behavior=add_child]").click

                  within ".dynamic-content-record-form" do
                    fill_in "Title", with: "Accomplishment 1 Title"
                    attach_file find("input[type='file']")[:id], Rails.root.join("test/fixtures/files/gobierto_common/document-1.pdf")
                  end
                end

                FileUploader::S3.any_instance.stubs(:call).returns("http://www.madrid.es/assets/documents/document-1.pdf")

                click_button "Update"

                # Assert it's created, and attachment is present

                within accomplishments_content_block do
                  assert_text "Accomplishment 1 Title"
                  assert_text "document-1.pdf"
                end

                # Create new record without attachment

                within accomplishments_content_block do
                  find("a[data-behavior=add_child]").click

                  within ".dynamic-content-record-form" do
                    fill_in "Title", with: "Accomplishment 2 Title"
                  end
                end

                click_button "Update"

                # Assert it's created without attachment

                within accomplishments_content_block do
                  assert has_text? "Accomplishment 1 Title"
                  assert has_text? "Accomplishment 2 Title"
                  assert has_content?("document-1.pdf", count: 1)
                end
              end
            end
          end
        end
      end
    end
  end
end
