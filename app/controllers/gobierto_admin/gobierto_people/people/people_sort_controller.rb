module GobiertoAdmin
  module GobiertoPeople
    module People
      class PeopleSortController < GobiertoAdmin::BaseController
        before_action { module_enabled!(current_site, "GobiertoPeople") }

        def create
          params[:positions].each do |_, item_attributes|
            if person = current_site.people.find_by(id: item_attributes['id'])
              person.update_column :position, item_attributes['position']
            end
          end
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
