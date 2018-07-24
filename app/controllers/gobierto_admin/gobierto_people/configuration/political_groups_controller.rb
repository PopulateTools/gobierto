module GobiertoAdmin
  module GobiertoPeople
    module Configuration
      class PoliticalGroupsController < BaseController
        before_action { gobierto_module_enabled!(current_site, "GobiertoPeople") }
        before_action { module_allowed!(current_admin, "GobiertoPeople") }

        def index
          @political_groups = ::GobiertoPeople::PoliticalGroup.all
        end

        def new
          @political_group_form = PoliticalGroupForm.new
        end

        def edit
          @political_group = find_political_group

          @political_group_form = PoliticalGroupForm.new(
            @political_group.attributes.except(*ignored_political_group_attributes)
          )
        end

        def create
          @political_group_form = PoliticalGroupForm.new(
            political_group_params.merge(
              admin_id: current_admin.id,
              site_id: current_site.id
            )
          )

          if @political_group_form.save
            redirect_to(
              edit_admin_people_configuration_political_group_path(@political_group_form.political_group),
              notice: t(".success")
            )
          else
            render :new
          end
        end

        def update
          @political_group = find_political_group
          @political_group_form = PoliticalGroupForm.new(
            political_group_params.merge(id: params[:id])
          )

          if @political_group_form.save
            redirect_to(
              edit_admin_people_configuration_political_group_path(@political_group),
              notice: t(".success")
            )
          else
            render :edit
          end
        end

        private

        def find_political_group
          ::GobiertoPeople::PoliticalGroup.find(params[:id])
        end

        def political_group_params
          params.require(:political_group).permit(:name)
        end

        def ignored_political_group_attributes
          %w( created_at updated_at position slug )
        end
      end
    end
  end
end
