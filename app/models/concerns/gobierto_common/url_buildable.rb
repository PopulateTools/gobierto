# frozen_string_literal: true

module GobiertoCommon
  module UrlBuildable

    extend ActiveSupport::Concern

    def to_path
      url_helpers.send("#{singular_route_key}_path", parameterize)
    end
    alias resource_path to_path

    def to_url(options = {})
      host_domain = try(:site)&.domain || app_host

      merge_preview_token_if_needed!(options)

      url_helpers.send(
        "#{singular_route_key}_url",
        parameterize.merge(host: host_domain)
                    .merge(options.except(:preview, :admin))
      )
    end

    def to_anchor
      "#{model_name.human.downcase}-#{id}"
    end

    private

    def parameterize
      { id: id }
    end

    def singular_route_key
      model_name.singular_route_key
    end

    def app_host
      @app_host ||= ENV.fetch("HOST") { "gobierto.test" }
    end

    def merge_preview_token_if_needed!(options)
      if (try(:public?) == false || try(:draft?)) && options[:preview] && options[:admin]
        options[:preview_token] = options[:admin].preview_token
      end
    end

  end
end
