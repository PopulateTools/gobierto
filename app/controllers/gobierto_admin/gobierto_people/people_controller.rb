module GobiertoAdmin
  module GobiertoPeople
    class PeopleController < BaseController
      include ::GobiertoCommon::DynamicContentHelper

      before_action { module_enabled!(current_site, "GobiertoPeople") }

      def index
        @people = current_site.people.sorted
      end

      def new
        @person_form = PersonForm.new(site_id: current_site.id)
        @person_visibility_levels = get_person_visibility_levels
      end

      def edit
        @person = find_person
        @person_visibility_levels = get_person_visibility_levels

        @person_form = PersonForm.new(
          @person.attributes.except(*ignored_person_attributes)
        )
      end

      def create
        @person_form = PersonForm.new(
          person_params.merge(
            admin_id: current_admin.id,
            site_id: current_site.id
          )
        )

        if @person_form.save
          redirect_to(
            edit_admin_people_person_path(@person_form.person),
            notice: t(".success")
          )
        else
          @person_visibility_levels = get_person_visibility_levels
          render :new
        end
      end

      def update
        @person = find_person
        @person_form = PersonForm.new(
          person_params.merge(id: params[:id])
        )

        if @person_form.save
          redirect_to(
            edit_admin_people_person_path(@person),
            notice: t(".success")
          )
        else
          @person_visibility_levels = get_person_visibility_levels
          render :edit
        end
      end

      private

      def find_person
        current_site.people.find(params[:id])
      end

      def get_person_visibility_levels
        ::GobiertoPeople::Person.visibility_levels
      end

      def person_params
        params.require(:person).permit(
          :name,
          :charge,
          :bio,
          :bio_url,
          :visibility_level,
          dynamic_content_attributes
        )
      end

      def ignored_person_attributes
        %w(
        created_at updated_at
        )
      end
    end
  end
end
