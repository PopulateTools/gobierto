class Admin::AdminsController < Admin::BaseController
  def index
    @admins = Admin.sorted.all
  end

  def show
    @admin = find_admin
  end

  def new
    @admin_form = Admin::AdminForm.new
    @site_modules = get_site_modules
    @sites = get_sites
    @admin_authorization_levels = get_admin_authorization_levels
  end

  def edit
    @admin = find_admin
    @admin_form = Admin::AdminForm.new(@admin.attributes)
    @site_modules = get_site_modules
    @sites = get_sites
    @admin_authorization_levels = get_admin_authorization_levels
  end

  def create
    @admin_form = Admin::AdminForm.new(admin_params.merge(creation_ip: remote_ip))
    @site_modules = get_site_modules
    @sites = get_sites
    @admin_authorization_levels = get_admin_authorization_levels

    if @admin_form.save
      redirect_to admin_admins_path, notice: 'Admin was successfully created.'
    else
      render :new
    end
  end

  def update
    @admin_form = Admin::AdminForm.new(admin_params.merge(id: params[:id]))
    @site_modules = get_site_modules
    @sites = get_sites
    @admin_authorization_levels = get_admin_authorization_levels

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

  def get_site_modules
    APP_CONFIG["site_modules"].map { |site_module| OpenStruct.new(site_module) }
  end

  def get_sites
    Site.select(:id, :domain).all
  end

  def get_admin_authorization_levels
    Admin.authorization_levels
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
end
