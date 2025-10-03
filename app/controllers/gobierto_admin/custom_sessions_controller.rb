# frozen_string_literal: true

module GobiertoAdmin
  class CustomSessionsController < BaseController
    skip_before_action :authenticate_admin!, only: [:new, :create, :destroy]
    skip_before_action :set_admin_site, only: [:new, :destroy]
    before_action :require_no_authentication, only: [:new, :create]

    helper_method :site_from_domain

    layout "gobierto_admin/layouts/sessions"

    def new
      redirect_to auth_path and return unless auth_modules_present?

      set_admin_session_forms
    end

    def create
      set_admin_session_forms

      if @admin_session_forms.values.any?(&:save)
        @valid_session_form = @admin_session_forms.values.find(&:valid?)
        @valid_session_form.admin.update_session_data(remote_ip)
        sign_in_admin(@valid_session_form.admin.id)
        redirect_to after_sign_in_path, notice: t("gobierto_admin.sessions.create.success")
      else
        flash.now[:alert] = t("gobierto_admin.sessions.create.error")
        render :new
      end
    end

    def destroy
      sign_out_admin
      leave_site
      redirect_to after_sign_out_path, notice: t("gobierto_admin.sessions.create.success")
    end

    private

    def set_admin_session_forms
      @admin_session_forms = site_from_domain.configuration.admin_auth_modules_data.inject({}) do |admin_session_forms, auth_module|
        admin_session_forms.merge(auth_module.name => GobiertoAdmin.const_get(auth_module.session_form).new(site: site_from_domain,
                                                                                                            creation_ip: remote_ip,
                                                                                                            data: params.permit!))
      end
    end

    def session_params
      params.require(:session).permit(:identifier, :password)
    end

  end
end
