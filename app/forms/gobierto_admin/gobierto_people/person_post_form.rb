module GobiertoAdmin
  module GobiertoPeople
    class PersonPostForm
      include ActiveModel::Model
      prepend ::GobiertoCommon::Trackable

      TAG_SEPARATOR = ","

      attr_accessor(
        :id,
        :admin_id,
        :site_id,
        :person_id,
        :title,
        :body,
        :body_source,
        :tags,
        :visibility_level
      )

      delegate :persisted?, to: :person_post

      validates :title, presence: true
      validates :person, presence: true

      trackable_on :person_post

      notify_changed :visibility_level

      def save
        save_person_post if valid?
      end

      def person_post
        @person_post ||= person_post_class.find_by(id: id).presence || build_person_post
      end

      def admin_id
        @admin_id ||= person.admin_id
      end

      def site_id
        @site_id ||= person.site_id
      end

      def admin
        @admin ||= Admin.find_by(id: admin_id)
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def person_id
        @person_id ||= person_post.person_id
      end

      def person
        @person ||= person_class.find_by(id: person_id)
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

      def notify?
        person_post.active?
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
          person_post_attributes.site_id = site_id
          person_post_attributes.title = title
          person_post_attributes.body = body
          person_post_attributes.body_source = body_source
          person_post_attributes.tags = tags
          person_post_attributes.visibility_level = visibility_level
        end

        if @person_post.valid?
          run_callbacks(:save) do
            @person_post.save
          end

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
