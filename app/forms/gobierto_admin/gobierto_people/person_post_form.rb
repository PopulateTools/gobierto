module GobiertoAdmin
  module GobiertoPeople
    class PersonPostForm
      include ActiveModel::Model

      TAG_SEPARATOR = ","

      attr_accessor(
        :id,
        :person_id,
        :title,
        :body,
        :tags,
        :visibility_level
      )

      delegate :persisted?, to: :person_post

      validates :title, presence: true
      validates :person, presence: true

      def save
        save_person_post if valid?
      end

      def person_post
        @person_post ||= person_post_class.find_by(id: id).presence || build_person_post
      end

      def person_id
        @person_id ||= person_post.person_id
      end

      def person
        @person ||= person_class.find_by(id: person_id)
      end

      def site_id
        @site_id ||= person.site_id
      end

      def visibility_level
        @visibility_level ||= "draft"
      end

      def tags
        return unless @tags.present?

        if @tags.respond_to?(:join)
          @tags.join(TAG_SEPARATOR + " ")
        else
          @tags.split(TAG_SEPARATOR).map(&:strip)
        end
      end

      private

      def build_person_post
        person_post_class.new
      end

      def person_post_class
        ::GobiertoPeople::PersonPost
      end

      def person_class
        ::GobiertoPeople::Person
      end

      def save_person_post
        @person_post = person_post.tap do |person_post_attributes|
          person_post_attributes.person_id = person_id
          person_post_attributes.title = title
          person_post_attributes.body = body
          person_post_attributes.tags = tags
          person_post_attributes.visibility_level = visibility_level
        end

        if @person_post.valid?
          @person_post.save

          @person_post
        else
          promote_errors(@person_post.errors)

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
