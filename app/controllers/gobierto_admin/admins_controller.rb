# frozen_string_literal: true

module GobiertoAdmin
  class AdminsController < BaseController
    before_action :managing_user

    def index
      @admins = Admin.sorted.all
    end

    def show
      @admin = find_admin
    end

    def new
      @admin_form = AdminForm.new(site: current_site)

      set_admin_policy
      set_sites
      set_admin_groups
      set_authorization_levels
    end

    def edit
      @admin = find_admin

      @admin_form = AdminForm.new(
        @admin.attributes.except(*ignored_admin_attributes).merge(
          permitted_sites: @admin.sites.pluck(:id),
          admin_group_ids: @admin.admin_groups.pluck(:id),
          site: current_site
        )
      )

      set_admin_policy
      set_sites
      set_admin_groups
      set_authorization_levels
      set_activities
    end

    def create
      random_password = generate_random_password

      @admin_form = AdminForm.new(
        admin_params.merge(
          creation_ip: remote_ip,
          password: random_password,
          password_confirmation: random_password,
          site: current_site
        )
      )

      set_admin_policy
      set_sites
      set_admin_groups
      set_authorization_levels

      if @admin_form.save
        track_create_activity
        redirect_to admin_admins_path, notice: t(".success")
      else
        render :new
      end
    end

    def update
      @admin = find_admin

      set_admin_policy
      raise Errors::NotAuthorized unless @admin_policy.update?

      @admin_form = AdminForm.new(admin_params.merge(id: params[:id], site: current_site))

      set_sites
      set_admin_groups
      set_authorization_levels
      set_activities

      if @admin_form.save
        track_update_activity
        redirect_to edit_admin_admin_path(@admin), notice: t(".success")
      else
        render :edit
      end
    end

    private

    def find_admin
      Admin.find(params[:id])
    end

    def admin_params
      params.require(:admin).permit(
        :email,
        :name,
        :password,
        :password_confirmation,
        :authorization_level,
        permitted_sites: [],
        admin_group_ids: []
      )
    end

    def ignored_admin_attributes
      %w(
      created_at updated_at password_digest god
      confirmation_token reset_password_token
      invitation_token invitation_sent_at preview_token
      )
    end

    def set_admin_policy
      @admin_policy = AdminPolicy.new(current_admin, @admin)
    end

    def set_sites
      @sites = Site.select(:id, :domain).all
    end

    def set_admin_groups
      @admin_groups = AdminGroup.where(site_id: current_site.id).all
    end

    def set_authorization_levels
      return unless @admin_policy.manage_authorization_levels?

      @admin_authorization_levels = Admin.authorization_levels
    end

    def set_activities
      @activities = ActivityCollectionDecorator.new(Activity.admin_activities(@admin).page(params[:page]))
    end

    def track_create_activity
      Publishers::AdminActivity.broadcast_event("admin_created", default_activity_params.merge({subject: @admin_form.admin}))
    end

    def track_update_activity
      Publishers::AdminActivity.broadcast_event("admin_updated", default_activity_params.merge({subject: @admin_form.admin, changes: @admin_form.admin.previous_changes.except(:updated_at)}))
    end

    def default_activity_params
      { ip: remote_ip, author: current_admin }
    end

    def managing_user
      redirect_to admin_users_path and return false unless current_admin.managing_user?
    end

    def generate_random_password
      SecureRandom.hex(8)
    end
  end
end
