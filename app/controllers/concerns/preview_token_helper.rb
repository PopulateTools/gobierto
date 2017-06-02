module PreviewTokenHelper
  extend ActiveSupport::Concern

  private

  def valid_preview_token?
    preview_token = params[:preview_token]
    preview_token && ::GobiertoAdmin::Admin.where(preview_token: preview_token).exists?
  end

end
