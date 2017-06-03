module GobiertoPeople
  module People
    class BaseController < GobiertoPeople::ApplicationController

      include PreviewTokenHelper

      before_action :set_person

      layout "gobierto_people/layouts/people"

      private

      def set_person
        @person = PersonDecorator.new(find_person)
      end

      protected

      def find_person
        people_scope.find_by!(slug: params[:person_slug])
      end

      def people_scope
        valid_preview_token? ? current_site.people : current_site.people.active
      end

    end
  end
end
