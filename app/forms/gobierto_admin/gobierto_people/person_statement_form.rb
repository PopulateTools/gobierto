# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPeople
    class PersonStatementForm < BaseForm

      include ::GobiertoCommon::DynamicContentFormHelper
      prepend ::GobiertoCommon::Trackable

      attr_accessor(
        :id,
        :admin_id,
        :site_id,
        :person_id,
        :title_translations,
        :published_on,
        :attachment_file,
        :attachment_url,
        :attachment_size,
        :visibility_level
      )

      delegate :persisted?, to: :person_statement

      validates :published_on, presence: true
      validates :title_translations, translated_attribute_presence: true

      trackable_on :person_statement

      notify_changed :visibility_level

      def save
        save_person_statement if valid?
      end

      def person_statement
        @person_statement ||= person_statement_class.find_by(id: id).presence || build_person_statement
      end
      alias content_context person_statement

      def person_id
        @person_id ||= person_statement.person_id
      end

      def person
        @person ||= person_class.find_by(id: person_id)
      end

      def admin_id
        @admin_id ||= person.admin_id
      end

      def admin
        @admin ||= Admin.find_by(id: admin_id)
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def attachment_url
        @attachment_url ||= begin
          return person_statement.attachment_url unless attachment_file.present?

          ::GobiertoCommon::FileUploadService.new(
            site: person.site,
            collection: person_statement.model_name.collection,
            attribute_name: :attachment,
            file: attachment_file,
            content_disposition: "attachment"
          ).upload!
        end
      end

      def attachment_size
        @attachment_size ||= begin
          return person_statement.attachment_size unless attachment_file.present?

          attachment_file.size
        end
      end

      def visibility_level
        @visibility_level ||= "draft"
      end

      def notify?
        person_statement.active?
      end

      def published_on
        @published_on ||= Time.current.to_date
      end

      private

      def build_person_statement
        person_statement_class.new(site_id: site_id)
      end

      def person_statement_class
        ::GobiertoPeople::PersonStatement
      end

      def person_class
        ::GobiertoPeople::Person
      end

      def save_person_statement
        @person_statement = person_statement.tap do |person_statement_attributes|
          person_statement_attributes.person_id = person_id
          person_statement_attributes.site_id = site_id
          person_statement_attributes.title_translations = title_translations
          person_statement_attributes.published_on = published_on
          person_statement_attributes.attachment_url = attachment_url
          person_statement_attributes.attachment_size = attachment_size
          person_statement_attributes.visibility_level = visibility_level
          person_statement_attributes.content_block_records = content_block_records
        end

        if @person_statement.valid?
          run_callbacks(:save) do
            @person_statement.save
          end

          @person_statement
        else
          promote_errors(@person_statement.errors)

          false
        end
      end

    end
  end
end
