class Admin::AdminsController < Admin::BaseController
  def index
    @admins = Admin.sorted.all
  end

  def show
    set_admin
  end

  def new
    @admin_form = Admin::AdminForm.new

    set_site_modules
    set_sites
    set_authorization_levels
  end

  def edit
    @admin = find_admin
    @admin_form = Admin::AdminForm.new(@admin.attributes.except(*ignored_admin_attributes))

    set_admin_policy
    set_site_modules
    set_sites
    set_authorization_levels
  end

  def create
    @admin_form = Admin::AdminForm.new(admin_params.merge(creation_ip: remote_ip))

    set_site_modules
    set_sites
    set_authorization_levels

    if @admin_form.save
      redirect_to admin_admins_path, notice: 'Admin was successfully created.'
    else
      render :new
    end
  end

  def update
    @admin = find_admin
    @admin_form = Admin::AdminForm.new(admin_params.merge(id: params[:id]))

    set_admin_policy
    set_site_modules
    set_sites
    set_authorization_levels

    if @admin_form.save
      redirect_to admin_admins_path, notice: 'Admin was successfully updated.'
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
      site_modules: [],
      site_ids: []
    )
  end

  def ignored_admin_attributes
    %w(
      created_at updated_at password_digest god
      confirmation_token reset_password_token
      invitation_token invitation_sent_at
    )
  end

  def set_admin_policy
    @admin_policy = Admin::AdminPolicy.new(current_admin, @admin)
  end

  def set_site_modules
    return if @admin_policy && !@admin_policy.manage_permissions?

    @site_modules = APP_CONFIG["site_modules"].map do |site_module|
      OpenStruct.new(site_module)
    end
  end

  def set_sites
    return if @admin_policy && !@admin_policy.manage_sites?

    @sites = Site.select(:id, :domain).all
  end

  def set_authorization_levels
    return if @admin_policy && !@admin_policy.manage_authorization_levels?

    @admin_authorization_levels = Admin.authorization_levels
  end
end
