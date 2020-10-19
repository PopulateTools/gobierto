# frozen_string_literal: true

module GobiertoData
  class Cache
    def self.etag(str, current_site)
      if str.blank?
        current_site.datasets.cache_key
      else
        current_site.datasets.cache_key + Digest::MD5.hexdigest(str)
      end
    end

    def self.last_modified(current_site)
      current_site.datasets.select("MAX(updated_at) as timestamp").to_a.first.timestamp
    end

    def self.query_cache(current_site, query, format, &block)
      # Skip cache when setting disabled
      return yield unless Rails.application.config.action_controller.perform_caching

      dirname = Rails.root.join("public/cache/gobierto_data/queries/#{current_site.datasets.cache_key}")
      FileUtils.mkdir_p(dirname)
      filename = "#{dirname}/#{Digest::MD5.hexdigest(query)}.#{format}"
      unless File.file?(filename)
        result = yield

        # There's an error in the execution and the response is a Hash with a key describing
        # the errors
        return result if result.is_a?(Hash) && result.has_key?(:errors)
        File.write(filename, result, mode: "wb+")
      end

      File.open(filename, "rb")
    end
  end
end

