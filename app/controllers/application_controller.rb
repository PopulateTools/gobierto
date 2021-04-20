# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SubmodulesHelper
  include ::GobiertoCommon::ModuleHelper
  include ::GobiertoCommon::FileUploadHelper
  include ::GobiertoCms::GlobalNavigation
  include ApplicationConcern

  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::UnknownFormat, with: :render_404
  rescue_from Errors::InvalidParameters, with: :render_bad_request

  helper_method(
    :helpers,
    :load_current_module_sub_sections,
    :current_site,
    :current_module,
    :current_module_class,
    :available_locales,
    :cache_key_preffix
  )

  before_action :apply_engines_overrides, :authenticate_user_in_site, :allow_iframe_embed

  def render_404
    render file: Rails.root.join("public/404.html"), status: 404, layout: false, handlers: [:erb], formats: [:html]
  end

  def render_bad_request
    render status: :bad_request, file: Rails.root.join("public/404.html"), layout: false, handlers: [:erb], format: [:html]
  end

  def helpers
    ActionController::Base.helpers
  end

  private

  # Setups the headers to allow being embed from an iFrame. More info at:
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/frame-ancestors
  #
  # Reads the allowed domain from the site configuration
  def allow_iframe_embed
    if current_site.configuration.configuration_variables["allowed_iframe_origin"].present?
      # To support IE
      response.headers["X-Frame-Options"] = "ALLOW-FROM #{current_site.configuration.configuration_variables["allowed_iframe_origin"]}"
      # Rest of modern browsers
      response.headers["Content-Security-Policy"] = "frame-ancestors #{current_site.configuration.configuration_variables["allowed_iframe_origin"]};"
    end
  end

  def default_url_options
    if params.has_key?(:embed)
      { embed: true }
    else
      {}
    end
  end

  def set_locale
    if available_locales.include?(preferred_locale)
      I18n.locale = cookies.permanent.signed[:locale] = preferred_locale.to_sym
    end
  end

  def preferred_locale
    @preferred_locale ||= begin
                            locale_param = params[:locale]
                            locale_cookie = cookies.signed[:locale] if available_locales.include?(cookies.signed[:locale])
                            site_locale = current_site.configuration.default_locale if current_site.present?

                            (locale_param || locale_cookie || site_locale || I18n.default_locale).to_s
                          end
  end

  def engine_overrides
    @engine_overrides ||= current_site.try(:engines_overrides)
  end

  def engine_overrides?
    engine_overrides.present?
  end

  def apply_engines_overrides
    return unless engine_overrides?

    engine_overrides.each do |engine|
      prepend_view_path Rails.root.join("vendor/gobierto_engines/#{ engine }/app/views")
    end
  end

  protected

  def raise_module_not_enabled(redirect = true)
    if redirect
      redirect_to(root_path) and return false
    else
      head :forbidden
    end
  end

  def overrided_root_redirect
    if !request.env["gobierto_welcome_override"] && request.path == current_site.root_path
      redirect_to root_path and return false
    end
  end
end
