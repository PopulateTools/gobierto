# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPeople
    class PersonForm < BaseForm

      include ::GobiertoCommon::DynamicContentFormHelper
      prepend ::GobiertoCommon::Trackable

      attr_accessor(
        :id,
        :admin_id,
        :site_id,
        :name,
        :charge_translations,
        :email,
        :bio_translations,
        :bio_source_translations,
        :bio_file,
        :bio_url,
        :avatar_file,
        :avatar_url,
        :visibility_level,
        :category,
        :political_group_id,
        :party,
        :logo_crop_x,
        :logo_crop_y,
        :logo_crop_w,
        :logo_crop_h
      )

      delegate :persisted?, to: :person

      validates :name, :site, :admin, presence: true

      trackable_on :person

      notify_changed :visibility_level

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

      def admin
        @admin ||= Admin.find_by(id: admin_id)
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def visibility_level
        @visibility_level ||= "draft"
      end

      def category
        @category ||= "politician"
      end

      def party
        return if category == "executive"

        @party ||= person.party
      end

      def political_group_id
        return if category == "executive"

        @political_group_id ||= person.political_group_id
      end

      def bio_url
        @bio_url ||= begin
          return person.bio_url unless bio_file.present?

          ::GobiertoCommon::FileUploadService.new(
            site: site,
            collection: person.model_name.collection,
            attribute_name: :bio,
            file: bio_file
          ).upload!
        end
      end

      def avatar_url
        @avatar_url ||= begin
          return person.avatar_url unless avatar_file.present?

          ::GobiertoCommon::FileUploadService.new(
            site: site,
            collection: person.model_name.collection,
            attribute_name: :avatar,
            file: avatar_file,
            x: logo_crop_x.to_f,
            y: logo_crop_y.to_f,
            w: logo_crop_w.to_f,
            h: logo_crop_h.to_f
          ).upload!
        end
      end

      def notify?
        person.active?
      end

      private

      def build_person
        person_class.new(site_id: site_id)
      end

      def person_class
        ::GobiertoPeople::Person
      end

      def save_person
        @person = person.tap do |person_attributes|
          person_attributes.admin_id = admin_id
          person_attributes.site_id = site_id
          person_attributes.name = name
          person_attributes.charge_translations = charge_translations
          person_attributes.email = email
          person_attributes.bio_translations = bio_translations
          person_attributes.bio_source_translations = bio_source_translations
          person_attributes.bio_url = bio_url
          person_attributes.avatar_url = avatar_url
          person_attributes.visibility_level = visibility_level
          person_attributes.category = category
          person_attributes.party = party
          person_attributes.political_group_id = political_group_id
          person_attributes.content_block_records = content_block_records
          person_attributes.google_calendar_token ||= person_class.generate_unique_secure_token
        end

        if @person.valid?
          run_callbacks(:save) do
            @person.save
          end

          @person
        else
          promote_errors(@person.errors)

          false
        end
      end

    end
  end
end
