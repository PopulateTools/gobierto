class Admin::SitesController < Admin::BaseController
  after_action :track_create_activity, only: [:create]
  after_action :track_update_activity, only: [:update]
  after_action :track_destroy_activity, only: [:destroy]

  def index
    @sites = SiteCollectionDecorator.new(current_admin.sites.sorted)
  end

  def new
    @site_form = Admin::SiteForm.new
    @site_modules = get_site_modules
    @site_visibility_levels = get_site_visibility_levels
    @dns_config = get_dns_config
  end

  def edit
    @site = find_site
    @site_form = Admin::SiteForm.new(@site.attributes)
    @site_modules = get_site_modules
    @site_visibility_levels = get_site_visibility_levels
    @dns_config = get_dns_config
  end

  def create
    @site_form = Admin::SiteForm.new(site_params.merge(creation_ip: remote_ip))
    @site_modules = get_site_modules
    @site_visibility_levels = get_site_visibility_levels
    @dns_config = get_dns_config

    if @site_form.save
      redirect_to admin_sites_path, notice: 'Site was successfully created.'
    else
      render :new
    end
  end

  def update
    @site_form = Admin::SiteForm.new(site_params.merge(id: params[:id]))
    @site_modules = get_site_modules
    @site_visibility_levels = get_site_visibility_levels
    @dns_config = get_dns_config

    if @site_form.save
      redirect_to admin_sites_path, notice: 'Site was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @site = find_site

    @site.destroy

    redirect_to admin_sites_path, notice: 'Site was successfully destroyed.'
  end

  private

  def find_site
    current_admin.sites.find(params[:id])
  end

  def get_site_modules
    APP_CONFIG["site_modules"].map { |site_module| OpenStruct.new(site_module) }
  end

  def get_dns_config
    OpenStruct.new(APP_CONFIG["dns_config"])
  end

  def get_site_visibility_levels
    Site.visibility_levels
  end

  def site_params
    params.require(:site).permit(
      :title,
      :name,
      :domain,
      :location_name,
      :location_type,
      :institution_url,
      :institution_type,
      :institution_email,
      :institution_address,
      :institution_document_number,
      :head_markup,
      :foot_markup,
      :visibility_level,
      :google_analytics_id,
      site_modules: []
    )
  end

  def track_create_activity
    Publishers::SiteActivity.broadcast_event("site_created", default_activity_params.merge({subject: @site_form.site}))
  end

  def track_update_activity
    Publishers::SiteActivity.broadcast_event("site_updated", default_activity_params.merge({subject: @site_form.site, changes: @site_form.site.previous_changes.except(:updated_at)}))
  end

  def track_destroy_activity
    Publishers::SiteActivity.broadcast_event("site_deleted", default_activity_params.merge({subject: @site}))
  end

  def default_activity_params
    { ip: remote_ip, author: current_admin }
  end
end
