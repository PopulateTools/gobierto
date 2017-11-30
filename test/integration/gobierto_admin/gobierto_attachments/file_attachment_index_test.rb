# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCms
    class FileAttachmentIndexTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_attachments_file_attachments_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def collections
        @collections ||= site.collections.where(item_type: "GobiertoAttachments::Attachment")
      end

      def test_attachments_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "#file_attachments_in_collection" do
              assert has_selector?("tr", count: collections.size)

              collections.each do |collection|
                assert has_selector?("tr#collection-item-#{collection.id}")

                within "tr#collection-item-#{collection.id}" do
                  assert has_link?(collection.title.to_s)
                end
              end
            end
          end
        end
      end
    end
  end
end
