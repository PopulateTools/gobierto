require 'test_helper'

module GobiertoAdmin
  module GobiertoParticipation
    class AttachmentsTest < ActionDispatch::IntegrationTest

      def setup
        super
        collection.append(attachment)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:gender_violence_process)
      end

      def collection
        @collection ||= gobierto_common_collections(:gender_violence_process_documents)
      end

      def attachment
        @attachment ||= gobierto_attachments_attachments(:pdf_attachment)
      end

      def test_attachments
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_participation_process_path(process)

            within '.tabs' do
              click_link 'Documents'
            end

            assert has_content?(attachment.name)
          end
        end
      end
    end
  end
end
