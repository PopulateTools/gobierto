module GobiertoPeople
  module People
    class BaseController < GobiertoPeople::ApplicationController

      include PreviewTokenHelper
      include DatesRangeHelper

      before_action :set_person

      layout "gobierto_people/layouts/people"

      private

      def set_person

        if valid_preview_token?
          redirect_to(
            gobierto_people_root_path,
            alert: t('gobierto_admin.admin_unauthorized')
          ) and return if !admin_permissions_for_person?

          @people_scope = current_site.people
        else
          @people_scope = current_site.people.active
        end

        @person = PersonDecorator.new(find_person)
      end

      protected

      def find_person
        @people_scope.find_by!(slug: params[:container_slug] || params[:person_slug])
      end

      def admin_permissions_for_person?
        person = current_site.people.find_by(slug: params[:container_slug] || params[:person_slug])
        if person && current_admin
          ::GobiertoAdmin::GobiertoPeople::PersonPolicy.new(
            current_admin: current_admin,
            current_site: current_site,
            person: person
          ).view?
        else
          false
        end
      end

    end
  end
end
