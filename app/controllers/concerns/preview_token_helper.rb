module PreviewTokenHelper
  extend ActiveSupport::Concern

  private

  def valid_preview_token?
    preview_token = params[:preview_token]
    preview_token && ::GobiertoAdmin::Admin.where(preview_token: preview_token).exists?
  end

  def current_admin
    @current_admin ||= begin
      valid_preview_token? ? ::GobiertoAdmin::Admin.find_by(preview_token: params[:preview_token]) : nil
    end
  end

end
