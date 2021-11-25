module HttpCache
  extend ActiveSupport::Concern

  def set_cache_headers
    if !defined?(:user_signed_in?) && user_signed_in?
      response.headers["Cache-Control"] = "private"
    else
      response.headers["Cache-Control"] = "public,#{60*60*24}" # 1 day
    end
  end
end
