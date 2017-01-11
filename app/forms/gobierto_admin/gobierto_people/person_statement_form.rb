module GobiertoAdmin
  module GobiertoPeople
    class PersonStatementForm
      include ActiveModel::Model
      include ::GobiertoCommon::DynamicContentFormHelper

      attr_accessor(
        :id,
        :person_id,
        :title,
        :published_on,
        :visibility_level
      )

      delegate :persisted?, to: :person_statement

      validates :title, presence: true
      validates :published_on, presence: true
      validates :person, presence: true

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

      def site_id
        @site_id ||= person.site_id
      end

      def published_on
        if @published_on.respond_to?(:strftime)
          return @published_on.strftime("%Y-%m-%d")
        end

        @published_on
      end

      def visibility_level
        @visibility_level ||= "draft"
      end

      private

      def build_person_statement
        person_statement_class.new
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
          person_statement_attributes.title = title
          person_statement_attributes.published_on = published_on
          person_statement_attributes.visibility_level = visibility_level
          person_statement_attributes.content_block_records = content_block_records
        end

        if @person_statement.valid?
          @person_statement.save

          @person_statement
        else
          promote_errors(@person_statement.errors)

          false
        end
      end

      protected

      def promote_errors(errors_hash)
        errors_hash.each do |attribute, message|
          errors.add(attribute, message)
        end
      end
    end
  end
end
