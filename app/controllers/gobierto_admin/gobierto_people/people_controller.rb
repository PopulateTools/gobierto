module GobiertoAdmin
  module GobiertoPeople
    class PeopleController < BaseController
      include ::GobiertoCommon::DynamicContentHelper

      before_action { module_enabled!(current_site, "GobiertoPeople") }
      before_action { module_allowed!(current_admin, "GobiertoPeople") }

      def index
        @people = current_site.people.sorted
      end

      def new
        @person_form = PersonForm.new(site_id: current_site.id)
        @person_visibility_levels = get_person_visibility_levels
        @person_categories = get_person_categories
        @person_parties = get_person_parties
        @political_groups = get_political_groups
      end

      def edit
        @person = find_person
        @person_visibility_levels = get_person_visibility_levels
        @person_categories = get_person_categories
        @person_parties = get_person_parties
        @political_groups = get_political_groups

        @person_form = PersonForm.new(
          @person.attributes.except(*ignored_person_attributes)
        )
      end

      def create
        @person_form = PersonForm.new(
          person_params.merge(admin_id: current_admin.id, site_id: current_site.id)
        )

        if @person_form.save
          redirect_to(
            edit_admin_people_person_path(@person_form.person),
            notice: t(".success_html", link: gobierto_people_person_url(@person_form.person.slug, host: current_site.domain))
          )
        else
          @person_visibility_levels = get_person_visibility_levels
          @person_categories = get_person_categories
          @person_parties = get_person_parties
          @political_groups = get_political_groups
          render :new
        end
      end

      def update
        @person = find_person
        @person_form = PersonForm.new(
          person_params.merge(id: params[:id], admin_id: current_admin.id, site_id: current_site.id)
        )

        if @person_form.save
          redirect_to(
            edit_admin_people_person_path(@person),
            notice: t(".success_html", link: gobierto_people_person_url(@person_form.person.slug, host: current_site.domain))
          )
        else
          @person_visibility_levels = get_person_visibility_levels
          @person_categories = get_person_categories
          @person_parties = get_person_parties
          @political_groups = get_political_groups
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

      def get_person_categories
        ::GobiertoPeople::Person.categories
      end

      def get_person_parties
        ::GobiertoPeople::Person.parties
      end

      def get_political_groups
        ::GobiertoPeople::PoliticalGroup.all
      end

      def person_params
        params.require(:person).permit(
          :name, :email, :bio_file, :avatar_file, :visibility_level, :category, :party, :political_group_id, :google_calendar_token,
          charge_translations: [*I18n.available_locales],
          bio_translations: [*I18n.available_locales],
          content_block_records_attributes: [
            :id,
            :content_block_id,
            :_destroy,
            fields_attributes: [:name, :value]
          ]
        )
      end

      def ignored_person_attributes
        %w( created_at updated_at events_count statements_count posts_count position charge bio slug google_calendar_token )
      end
    end
  end
end
