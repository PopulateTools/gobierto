# frozen_string_literal: true

class ApiBaseController < ActionController::API
  include SubmodulesHelper
  include ::GobiertoCommon::ModuleHelper
  include ApplicationConcern

  def preferred_locale
    @preferred_locale ||= begin
                            locale_param = params[:locale]
                            site_locale = current_site.configuration.default_locale if current_site.present?
                            (locale_param || site_locale || I18n.default_locale).to_s
                          end
  end

  def set_locale
    if available_locales.include?(preferred_locale)
      I18n.locale = preferred_locale.to_sym
    end
  end

  protected

  def raise_module_not_enabled(_redirect)
    head :forbidden
  end

end
