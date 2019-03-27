# frozen_string_literal: true

module GobiertoAdmin
  class Sites::SessionsController < BaseController
    def create
      if allowed_site?(params[:site_id])
        enter_site(params[:site_id])
        redirect_to(redirect_path)
      else
        raise_admin_not_authorized
      end
    end

    def destroy
      leave_site
      redirect_to(request.referrer)
    end

    private

    def redirect_path
      if URI(request.referrer).path == edit_admin_site_path(current_site)
        return edit_admin_site_path(id: params[:site_id])
      end

      request.referrer
    end

    def allowed_site?(site_id)
      site_id.to_i.in?(managed_sites.map(&:id))
    end
  end
end
