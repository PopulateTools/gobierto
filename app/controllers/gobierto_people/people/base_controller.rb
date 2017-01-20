module GobiertoPeople
  module People
    class BaseController < GobiertoPeople::ApplicationController
      before_action :set_person

      layout "gobierto_people/layouts/people"

      private

      def set_person
        @person = PersonDecorator.new(find_person)
      end

      protected

      def find_person
        current_site.people.active.find(params[:person_id])
      end
    end
  end
end
