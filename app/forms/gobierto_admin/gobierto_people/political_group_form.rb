# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPeople
    class PoliticalGroupForm < BaseForm

      attr_accessor(
        :id,
        :admin_id,
        :site_id,
        :name
      )

      delegate :persisted?, to: :political_group

      validates :name, presence: true
      validates :admin, :site, presence: true

      def save
        save_political_group if valid?
      end

      def political_group
        @political_group ||= political_group_class.find_by(id: id).presence || build_political_group
      end

      def admin_id
        @admin_id ||= political_group.admin_id
      end

      def site_id
        @site_id ||= political_group.site_id
      end

      def admin
        @admin ||= Admin.find_by(id: admin_id)
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      private

      def build_political_group
        political_group_class.new
      end

      def political_group_class
        ::GobiertoPeople::PoliticalGroup
      end

      def save_political_group
        @political_group = political_group.tap do |political_group_attributes|
          political_group_attributes.admin_id = admin_id
          political_group_attributes.site_id = site_id
          political_group_attributes.name = name
        end

        if @political_group.valid?
          @political_group.save

          @political_group
        else
          promote_errors(@political_group.errors)

          false
        end
      end

    end
  end
end
