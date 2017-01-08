module GobiertoAdmin
  module GobiertoPeople
    class PersonForm
      include ActiveModel::Model
      include ::GobiertoCommon::DynamicContentFormHelper

      attr_accessor(
        :id,
        :admin_id,
        :site_id,
        :name,
        :charge,
        :bio,
        :bio_url,
        :visibility_level
      )

      delegate :persisted?, to: :person

      validates :name, presence: true
      validates :admin, :site, presence: true

      def save
        save_person if valid?
      end

      def person
        @person ||= person_class.find_by(id: id).presence || build_person
      end
      alias content_context person

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

      def visibility_level
        @visibility_level ||= "draft"
      end

      private

      def build_person
        person_class.new
      end

      def person_class
        ::GobiertoPeople::Person
      end

      def save_person
        @person = person.tap do |person_attributes|
          person_attributes.admin_id = admin_id
          person_attributes.site_id = site_id
          person_attributes.name = name
          person_attributes.charge = charge
          person_attributes.bio = bio
          person_attributes.bio_url = bio_url
          person_attributes.visibility_level = visibility_level
          person_attributes.content_block_records = content_block_records
        end

        if @person.valid?
          @person.save

          @person
        else
          promote_errors(@person.errors)

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
