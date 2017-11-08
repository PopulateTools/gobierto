module GobiertoAdmin
  class SitesController < BaseController
    def index
      site_policy = SitePolicy.new(current_admin)
      raise Errors::NotAuthorized unless site_policy.view?

      @sites = SiteCollectionDecorator.new(current_admin.sites.sorted)
    end

    def new
      site_policy = SitePolicy.new(current_admin)
      raise Errors::NotAuthorized unless site_policy.create?

      @site_form = SiteForm.new
      @site_modules = get_site_modules
      @site_modules_with_root_path = site_modules_with_root_path
      @site_visibility_levels = get_site_visibility_levels
      @dns_config = get_dns_config
      @services_config = get_services_config
      @available_locales_for_site = get_available_locales
      @available_pages = get_available_pages
    end

    def edit
      @site = find_site

      site_policy = SitePolicy.new(current_admin, @site)
      raise Errors::NotAuthorized unless site_policy.update?

      @site_form = SiteForm.new(
        @site.attributes.except(*ignored_site_attributes)
      )
      @site_modules = get_site_modules
      @site_modules_with_root_path = site_modules_with_root_path
      @site_visibility_levels = get_site_visibility_levels
      @dns_config = get_dns_config
      @services_config = get_services_config
      @available_locales_for_site = get_available_locales
      @available_pages = get_available_pages
    end

    def create
      @site_form = SiteForm.new(site_params.merge(creation_ip: remote_ip))

      site_policy = SitePolicy.new(current_admin, @site_form.site)
      raise Errors::NotAuthorized unless site_policy.create?

      @site_modules = get_site_modules
      @site_modules_with_root_path = site_modules_with_root_path
      @site_visibility_levels = get_site_visibility_levels
      @dns_config = get_dns_config
      @services_config = get_services_config
      @available_locales_for_site = get_available_locales
      @available_pages = get_available_pages

      if @site_form.save
        track_create_activity
        redirect_to admin_sites_path, notice: t(".success")
      else
        render :new
      end
    end

    def update
      @site = find_site
      @site_form = SiteForm.new(site_params.merge(id: params[:id]))

      site_policy = SitePolicy.new(current_admin, @site_form.site)
      raise Errors::NotAuthorized unless site_policy.update?

      @site_modules = get_site_modules
      @site_modules_with_root_path = site_modules_with_root_path
      @site_visibility_levels = get_site_visibility_levels
      @dns_config = get_dns_config
      @services_config = get_services_config
      @available_locales_for_site = get_available_locales
      @available_pages = get_available_pages

      if @site_form.save
        track_update_activity
        redirect_to edit_admin_site_path(@site), notice: t(".success")
      else
        render :edit
      end
    end

    def destroy
      @site = find_site

      site_policy = SitePolicy.new(current_admin, @site)
      raise Errors::NotAuthorized unless site_policy.delete?

      @site.destroy
      track_destroy_activity

      redirect_to admin_sites_path, notice: t(".success")
    end

    private

    def find_site
      current_admin.sites.find(params[:id])
    end

    def get_site_modules
      APP_CONFIG["site_modules"].map { |site_module| OpenStruct.new(site_module) }
    end

    def site_modules_with_root_path
      APP_CONFIG["site_modules_with_root_path"].map { |site_module| OpenStruct.new(site_module) }
    end

    def get_dns_config
      OpenStruct.new(APP_CONFIG["dns_config"])
    end

    def get_services_config
      OpenStruct.new(APP_CONFIG["services"])
    end

    def get_site_visibility_levels
      Site.visibility_levels
    end

    def site_params
      params.require(:site).permit(
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
        :links_markup,
        :visibility_level,
        :google_analytics_id,
        :username,
        :password,
        :municipality_id,
        :logo_file,
        :default_locale,
        :privacy_page_id,
        :populate_data_api_token,
        :home_page,
        site_modules: [],
        available_locales: [],
        title_translations: [*I18n.available_locales],
        name_translations: [*I18n.available_locales]
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

    def get_available_locales
      available_locales.map{ |l| [l.to_s, I18n.t("locales.#{l}")] }
    end

    def get_available_pages
      @site.pages.active.sorted
    end

    def ignored_site_attributes
      %w( name title )
    end
  end
end
