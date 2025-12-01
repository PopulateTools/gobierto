# frozen_string_literal: true

module GobiertoAdmin
  class AdminGroupsController < BaseController
    CORE_MODULES = [{ name: "Gobierto CMS", namespace: "GobiertoCms" }].freeze

    before_action :managing_user

    def index
      @admin_groups = AdminGroup.where(site: current_site).normal
    end

    def new
      @admin_group_form = AdminGroupForm.new(site_id: current_site.id)

      set_admin_policy
      set_site_modules
      set_site_options
      set_people
    end

    def edit
      @admin_group = find_admin_group

      @admin_group_form = AdminGroupForm.new(
        @admin_group.attributes.except(*ignored_admin_group_attributes).merge(
          modules_actions: @admin_group.modules_permissions.distinct.pluck(:resource_type).map do |resource_type|
            [resource_type,
             @admin_group.modules_permissions.where(resource_type: resource_type).distinct.pluck(:action_name)]
          end.to_h,
          people: @admin_group.people_permissions.where(action_name: "manage").pluck(:resource_id),
          site_options: @admin_group.site_options_permissions.where(action_name: "manage").pluck(:resource_type),
          all_people: @admin_group.people_permissions.where(action_name: "manage_all").exists?
        )
      )

      set_admin_policy
      set_site_modules
      set_site_options
      set_people
    end

    def create
      @admin_group_form = AdminGroupForm.new(admin_group_params.merge(site_id: current_site.id))

      set_admin_policy
      set_site_modules
      set_site_options
      set_people

      if @admin_group_form.save
        track_create_activity
        redirect_to admin_admin_groups_path, notice: t(".success")
      else
        render :new
      end
    end

    def update
      @admin_group = find_admin_group

      set_admin_policy
      raise Errors::NotAuthorized unless @admin_policy.update?

      @admin_group_form = AdminGroupForm.new(admin_group_params.merge(id: params[:id], site_id: current_site.id))

      set_site_modules
      set_site_options
      set_people

      if @admin_group_form.save
        track_update_activity
        redirect_to edit_admin_admin_group_path(@admin_group), notice: t(".success")
      else
        render :edit
      end
    end

    private

    def find_admin_group
      AdminGroup.normal.find(params[:id])
    end

    def admin_group_params
      params.require(:admin_group).permit(
        :name,
        :all_people,
        people: [],
        site_options: [],
        modules_actions: {}
      )
    end

    def ignored_admin_group_attributes
      ["group_type"]
    end

    def set_admin_policy
      @admin_policy = AdminPolicy.new(current_admin)
    end

    def set_site_modules
      @site_modules = APP_CONFIG[:site_modules].map do |site_module|
        next unless current_site.configuration.modules.include? site_module[:namespace]

        OpenStruct.new(site_module)
      end.push(*core_modules).compact
    end

    def core_modules
      CORE_MODULES.map { |mod| OpenStruct.new(mod) }
    end

    def set_site_options
      @site_options = Permission::SiteOption::RESOURCE_TYPES.map do |option_name|
        OpenStruct.new(
          name: option_name,
          label_text: Permission::SiteOption.label_text(option_name)
        )
      end
    end

    def set_people
      @people = current_site.people
    end

    def track_create_activity
      Publishers::AdminActivity.broadcast_event(
        "admin_group_created",
        default_activity_params.merge(subject: @admin_group_form.admin_group)
      )
    end

    def track_update_activity
      Publishers::AdminActivity.broadcast_event(
        "admin_group_updated",
        default_activity_params.merge(
          subject: @admin_group_form.admin_group,
          changes: @admin_group_form.admin_group.previous_changes
        )
      )
    end

    def default_activity_params
      { ip: remote_ip, author: current_admin }
    end

    def managing_user
      redirect_to admin_users_path and return false unless current_admin.managing_user?
    end
  end
end
