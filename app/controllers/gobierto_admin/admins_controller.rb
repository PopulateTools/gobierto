# frozen_string_literal: true

module GobiertoAdmin
  class AdminsController < BaseController
    before_action :managing_user

    def index
      @admins = base_scope.sorted
    end

    def show
      @admin = find_admin
    end

    def new
      new_form_attributes = { site: current_site }
      new_form_attributes[:permitted_sites] = available_sites.pluck(:id) if available_sites.one?

      @admin_form = AdminForm.new(new_form_attributes)

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
        ).merge(
          restricted_permitted_sites(admin: @admin)
        )
      )

      set_admin_policy
      set_sites
      set_admin_groups
      set_authorization_levels
      set_activities
      set_api_tokens
    end

    def create
      random_password = generate_random_password

      @admin_form = AdminForm.new(
        admin_params.merge(
          creation_ip: remote_ip,
          password: random_password,
          password_confirmation: random_password,
          site: current_site
        ).merge(
          restricted_permitted_sites(params: admin_params)
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

      @admin_form = AdminForm.new(admin_params.merge(id: params[:id], site: current_site).merge(restricted_permitted_sites(admin: @admin, params: admin_params)))

      set_sites
      set_admin_groups
      set_authorization_levels
      set_activities
      set_api_tokens

      if @admin_form.save
        track_update_activity
        redirect_to edit_admin_admin_path(@admin), notice: t(".success")
      else
        render :edit
      end
    end

    private

    def find_admin
      base_scope.find(params[:id])
    end

    def base_scope
      if current_admin.managing_user?
        Admin.all
      else
        Admin.regular_or_disabled_on_site(current_site)
      end
    end

    def available_sites
      @available_sites ||= if current_admin.managing_user?
        Site.all
      else
        current_admin.sites
      end
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

    def restricted_permitted_sites(admin: nil, params: {})
      return {} if current_admin.managing_user?

      current_admin_sites = current_admin.admin_sites.pluck(:site_id)
      admin_sites = params.present? ? params[:permitted_sites] : admin&.admin_sites&.pluck(:site_id)&.map(&:to_s)
      permitted_sites = current_admin_sites.select { |id| admin_sites.include?(id.to_s) }.presence || [current_site.id]

      { permitted_sites: }
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
      @sites = available_sites.select(:id, :domain)
    end

    def set_admin_groups
      @admin_groups = AdminGroup.normal.where(site_id: current_site.id).all
    end

    def set_authorization_levels
      return unless @admin_policy.manage_authorization_levels?

      @admin_authorization_levels = Admin.authorization_levels
    end

    def set_activities
      @activities = ActivityCollectionDecorator.new(Activity.admin_activities(@admin).page(params[:page]))
    end

    def set_api_tokens
      @api_tokens = @admin.api_tokens
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
      redirect_to admin_users_path and return false unless current_admin.can_manage_admins?
    end

    def generate_random_password
      SecureRandom.hex(8)
    end
  end
end
