module HttpCache
  extend ActiveSupport::Concern

  def set_cache_headers
    if user_signed_in?
      response.headers["Cache-Control"] = "private"
    else
      response.headers["Cache-Control"] = "public,#{60*60*24}" # 1 day
    end
  rescue NoMethodError
    response.headers["Cache-Control"] = "private"
  end
end
