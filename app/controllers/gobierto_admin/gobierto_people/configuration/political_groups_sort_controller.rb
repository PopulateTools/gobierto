module GobiertoAdmin
  module GobiertoPeople
    module Configuration
      class PoliticalGroupsSortController < BaseController
        before_action { gobierto_module_enabled!(current_site, "GobiertoPeople") }
        before_action { module_allowed!(current_admin, "GobiertoPeople") }

        def create
          ::GobiertoPeople::PoliticalGroup.update_positions(political_group_sort_params)
          head :no_content
        end

        private

        def political_group_sort_params
          params.require(:positions).permit!
        end
      end
    end
  end
end
