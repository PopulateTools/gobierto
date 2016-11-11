class Admin::Sites::SessionsController < Admin::BaseController
  def create
    if allowed_site?(params[:site_id])
      enter_site(params[:site_id])
      redirect_to(request.referrer)
    else
      raise_admin_not_authorized
    end
  end

  def destroy
    leave_site
    redirect_to(request.referrer)
  end

  private

  def allowed_site?(site_id)
    site_id.to_i.in?(managed_sites.map(&:id))
  end
end
