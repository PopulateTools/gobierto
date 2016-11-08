class Admin::SitesController < Admin::BaseController
  def index
    @sites = SiteCollectionDecorator.new(current_admin.sites)
  end

  def show
    @site = find_site
  end

  def new
    @site_form = SiteForm.new
  end

  def edit
    @site = find_site
    @site_form = SiteForm.new(@site.attributes)
  end

  def create
    @site_form = SiteForm.new(site_params)

    if @site_form.save
      redirect_to admin_sites_path, notice: 'Site was successfully created.'
    else
      render :new
    end
  end

  def update
    @site_form = SiteForm.new(site_params.merge(id: params[:id]))

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
    Site.find(params[:id])
  end

  def site_params
    params.require(:site_form).permit(
      :name,
      :domain,
      :configuration_data,
      :location_name,
      :location_type,
      :institution_url,
      :institution_type,
      :institution_email,
      :institution_address,
      :institution_document_number,
      :head_markup,
      :foot_markup
    )
  end
end
