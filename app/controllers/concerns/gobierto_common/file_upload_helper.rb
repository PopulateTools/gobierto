# frozen_string_literal: true

module GobiertoCommon
  module FileUploadHelper
    extend ActiveSupport::Concern

    included do
      helper_method :pretty_filename_url
    end

    private

    def pretty_filename_url(filename_url)
      filename_url.split("/").last.last(40)
    end

  end
end
