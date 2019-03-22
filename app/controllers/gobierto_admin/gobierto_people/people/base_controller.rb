module GobiertoAdmin
  module GobiertoPeople
    module People
      class BaseController < GobiertoAdmin::BaseController
        before_action { module_enabled!(current_site, "GobiertoPeople") }
        before_action { module_allowed!(current_admin, "GobiertoPeople") }

        before_action :set_person
        before_action :person_allowed!

        private

        def set_person
          @person = find_person
        end

        protected

        def find_person
          current_site.people.find(params[:person_id])
        end

        def person_allowed!
          person_policy = PersonPolicy.new(current_admin: current_admin, current_site: current_site, person: @person)
          if !person_policy.manage?
            redirect_to admin_people_people_path, alert: t('gobierto_admin.admin_unauthorized')
          end
        end
      end
    end
  end
end
