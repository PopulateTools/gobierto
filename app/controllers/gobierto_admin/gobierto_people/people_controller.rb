# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPeople
    class PeopleController < BaseController
      include ::GobiertoCommon::DynamicContentHelper

      before_action { module_enabled!(current_site, "GobiertoPeople") }
      before_action { module_allowed!(current_admin, "GobiertoPeople") }
      before_action :create_person_allowed!, only: [:new, :create]
      before_action :manage_person_allowed!, only: [:edit, :update]

      helper_method :gobierto_people_person_preview_url

      def index
        @people = current_site.people.sorted
        @preview_item_url = gobierto_people_people_url(host: current_site.domain)
        @can_create_person = site_people_policy.create?
        @manage_all_people = site_people_policy.manage_all_people_in_site?
      end

      def new
        @person_form = PersonForm.new(site_id: current_site.id)
        @person_visibility_levels = get_person_visibility_levels
        @person_categories = get_person_categories
        @person_parties = get_person_parties
        @political_groups = get_political_groups
      end

      def edit
        @person_visibility_levels = get_person_visibility_levels
        @person_categories = get_person_categories
        @person_parties = get_person_parties
        @political_groups = get_political_groups

        @person_form = PersonForm.new(
          @person.attributes.except(*ignored_person_attributes).merge(site_id: current_site.id)
        )
      end

      def create
        @person_form = PersonForm.new(person_params.merge(admin_id: current_admin.id, site_id: current_site.id))

        if @person_form.save
          redirect_to(
            edit_admin_people_person_path(@person_form.person),
            notice: t(".success_html", link: gobierto_people_person_preview_url(@person_form.person, host: current_site.domain))
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
        @person_form = PersonForm.new(person_params.merge(id: params[:id],
                                                          admin_id: current_admin.id,
                                                          site_id: current_site.id,
                                                          logo_crop_x: params[:person][:logo_crop_x],
                                                          logo_crop_y: params[:person][:logo_crop_y],
                                                          logo_crop_w: params[:person][:logo_crop_w],
                                                          logo_crop_h: params[:person][:logo_crop_h]))

        if @person_form.save
          redirect_to(
            edit_admin_people_person_path(@person),
            notice: t(".success_html", link: gobierto_people_person_preview_url(@person_form.person, host: current_site.domain))
          ) and return
        else
          @person_visibility_levels = get_person_visibility_levels
          @person_categories = get_person_categories
          @person_parties = get_person_parties
          @political_groups = get_political_groups
          render :edit
        end
      end

      private

      def load_person
        @person = current_site.people.find(params[:id])
        @preview_item = @person
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
        current_site.political_groups
      end

      def person_params
        params.require(:person).permit(
          :name, :email, :bio_file, :avatar_file, :visibility_level, :category,
          :party, :political_group_id, :google_calendar_token,
          :logo_crop_x, :logo_crop_y, :logo_crop_w, :logo_crop_h,
          charge_translations: [*I18n.available_locales],
          bio_translations: [*I18n.available_locales],
          bio_source_translations: [*I18n.available_locales],
          content_block_records_attributes: [
            :id,
            :content_block_id,
            :_destroy,
            :remove_attachment,
            :attachment_file,
            fields_attributes: [:name, :value]
          ]
        )
      end

      def ignored_person_attributes
        %w(created_at updated_at statements_count posts_count position charge bio slug google_calendar_token site_id)
      end

      def gobierto_people_person_preview_url(person, options = {})
        options.merge!(preview_token: current_admin.preview_token) unless person.active?
        gobierto_people_person_url(person.slug, options)
      end

      def manage_person_allowed!
        load_person

        if !PersonPolicy.new(current_admin: current_admin, current_site: current_site, person: @person).manage?
          redirect_to(admin_people_people_path, alert: t("gobierto_admin.admin_unauthorized")) and return false
        end
      end

      def create_person_allowed!
        if !PersonPolicy.new(current_admin: current_admin, current_site: current_site).create?
          redirect_to(admin_people_people_path, alert: t("gobierto_admin.admin_unauthorized")) and return false
        end
      end

      def site_people_policy
        PersonPolicy.new(current_admin: current_admin, current_site: current_site)
      end
    end
  end
end
