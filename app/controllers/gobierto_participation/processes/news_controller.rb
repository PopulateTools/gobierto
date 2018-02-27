# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class NewsController < BaseController
      def index
        @pages = find_process_news

        render "gobierto_participation/news/index"
      end

      private

      def find_process_news
        current_process.news.sorted.page(params[:page]).active
      end
    end
  end
end
