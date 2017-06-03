module GobiertoAdmin
  module GobiertoPeople
    module People
      class PeopleSortController < GobiertoAdmin::BaseController
        before_action { module_enabled!(current_site, "GobiertoPeople") }
        before_action { module_allowed!(current_admin, "GobiertoPeople") }

        def create
          current_site.people.update_positions(people_sort_params)
          head :no_content
        end

        private

        def people_sort_params
          params.require(:positions).permit!
        end
      end
    end
  end
end
