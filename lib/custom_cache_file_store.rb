class CustomCacheFileStore < ActiveSupport::Cache::MemoryStore

  def initialize(*args)
    super(*args)
    @cache_keys = {}
  end

  def write(*args)
    super
    @cache_keys[ args[0] ] = true
  end

  def delete(*args)
    super
    @cache_keys.delete(args[0])
  end

  def keys
    @cache_keys.keys
  end

  def clear
    keys.each do |key|
      delete(key) if key.exclude?("webpack")
    end
  end

end
