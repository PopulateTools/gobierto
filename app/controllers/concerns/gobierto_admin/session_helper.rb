# frozen_string_literal: true

module GobiertoAdmin
  module SessionHelper
    extend ActiveSupport::Concern

    private

    def current_admin
      @current_admin ||= find_current_admin
    end

    def admin_signed_in?
      current_admin.present?
    end

    def sign_in_admin(admin_id)
      session[:admin_id] = admin_id
    end

    def sign_out_admin
      @current_admin = session[:admin_id] = nil
    end

    def authenticate_admin!
      raise_admin_not_signed_in unless admin_signed_in?
    end

    def require_no_authentication
      raise_admin_already_authenticated if admin_signed_in?
    end

    def find_current_admin
      Admin.find_by(id: session[:admin_id])
    end

    def after_sign_in_path
      admin_root_path
    end

    def after_sign_out_path
      admin_root_path
    end

    def raise_admin_not_signed_in
      redirect_to(
        new_admin_sessions_path,
        alert: t("gobierto_admin.session_helper.not_signed_in")
      )
    end

    def raise_admin_not_authorized
      redirect_to(
        request.referrer || admin_root_path,
        alert: t("gobierto_admin.session_helper.not_authorized")
      )
    end

    def raise_admin_already_authenticated
      redirect_to(
        after_sign_in_path,
        alert: t("gobierto_admin.session_helper.already_signed_in")
      )
    end
  end
end
