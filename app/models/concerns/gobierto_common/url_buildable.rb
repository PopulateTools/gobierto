# frozen_string_literal: true

module GobiertoCommon
  module UrlBuildable

    extend ActiveSupport::Concern

    def to_path
      url_helpers.send("#{singular_route_key}_path", parameterize)
    end
    alias resource_path to_path

    def to_url(options = {})
      url_helpers.send(
        "#{singular_route_key}_url",
        parameterize.merge(host: app_host).merge(options)
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

  end
end
