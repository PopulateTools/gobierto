module GobiertoAdmin
  module GobiertoPeople
    module People
      class BaseController < GobiertoAdmin::BaseController
        before_action { module_enabled!(current_site, "GobiertoPeople") }
        before_action :set_person

        private

        def set_person
          @person = find_person
        end

        protected

        def find_person
          current_site.people.find(params[:person_id])
        end
      end
    end
  end
end
