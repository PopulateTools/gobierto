# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module ContentBlockRecords
      class ContentBlockRecordTest < ActionDispatch::IntegrationTest
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
                    attach_file find("input[type='file']")[:id], "test/fixtures/files/gobierto_common/document-1.pdf"
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

        def test_content_block_record_update
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                within accomplishments_content_block do
                  assert has_content? "nobel_prize.pdf"
                  assert has_content? "marathon_certificate.pdf"

                  edit_links = all("a[data-behavior=edit_record]", visible: false)
                  content_block_records = all(".dynamic-content-record-wrapper")

                  # Update title and attachment for first record
                  edit_links[0].trigger(:click)
                  within(content_block_records[0]) do
                    fill_in "Title", with: "Accomplishment 1 Edited Title"
                    attach_file find("input[type='file']")[:id], "test/fixtures/files/gobierto_common/document-1.pdf"
                    find("a[data-behavior=add_record]").click
                  end

                  # Update title and attachment for second record
                  edit_links[1].trigger(:click)
                  within(content_block_records[1]) do
                    fill_in "Title", with: "Accomplishment 2 Edited Title"
                    attach_file find("input[type='file']")[:id], "test/fixtures/files/gobierto_common/document-2.pdf"
                    find("a[data-behavior=add_record]").click
                  end

                  # Remove attachment for third record
                  edit_links[2].trigger(:click)
                  # WARNING: it's third record inside accomplishments, but fifth record in total
                  find("#person_content_block_records_attributes_8_remove_attachment", visible: false).trigger(:click)
                end

                FileUploader::S3.any_instance.stubs(:call).returns("http://www.madrid.es/assets/documents/document-1.pdf", "http://www.madrid.es/assets/documents/document-2.pdf")

                click_button "Update"

                within accomplishments_content_block do
                  assert has_content? "Accomplishment 1 Edited Title"
                  assert has_content? "document-1.pdf"
                  refute has_content? "nobel_prize.pdf"

                  assert has_content? "Accomplishment 2 Edited Title"
                  assert has_content? "document-2.pdf"
                  refute has_content? "marathon_certificate.pdf"

                  assert has_content? "Ate 33 meatballs in 45 minutes"
                  refute has_content? "meatballs_photo.png"
                end
              end
            end
          end
        end

        def test_content_block_record_delete
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                # Delete second record

                within accomplishments_content_block do
                  delete_links = all("a[data-behavior=delete_record]", visible: false)
                  delete_links[1].trigger(:click)
                end

                click_button "Update"

                within accomplishments_content_block do
                  assert has_content? "Nobel Prize in Chemistry"
                  assert has_content? "nobel_prize.pdf"

                  refute has_content? "Ran New York marathon"
                  refute has_content? "marathon_certificate.pdf"

                  assert has_content? "Ate 33 meatballs in 45 minutes"
                end
              end
            end
          end
        end
      end
    end
  end
end
