module GobiertoAdmin
  module GobiertoPeople
    module People
      class PeopleSortController < GobiertoAdmin::BaseController
        before_action { module_enabled!(current_site, "GobiertoPeople") }
        before_action { module_allowed!(current_admin, "GobiertoPeople") }

        def create
          current_site.people.update_positions(people_sort_params) if manage_all_people_in_site?
          head :no_content
        end

        private

        def people_sort_params
          params.require(:positions).permit!
        end

        def manage_all_people_in_site?
          ::GobiertoAdmin::GobiertoPeople::PersonPolicy.new(current_admin: current_admin, current_site: current_site).manage_all_people_in_site?
        end

      end
    end
  end
end
