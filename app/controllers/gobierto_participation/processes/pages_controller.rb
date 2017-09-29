# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class PagesController < BaseController
      include ::PreviewTokenHelper

      before_action :find_page_by_id_and_redirect

      def show
        @process = find_process if params[:process_id]
        @page = find_page
        @groups = current_site.processes.group_process
      end

      def index
        @issues = current_site.issues
        @issue = find_issue if params[:issue_id]
        @pages = find_process_news.page(params[:page])
      end

      private

      # Load page by ID is necessary to keep the search results page unified and simple
      def find_page_by_id_and_redirect
        if params[:id].present? && params[:id] =~ /\A\d+\z/
          page = current_site.pages.active.find(params[:id])
          redirect_to gobierto_cms_page_path(page.slug) and return false
        end
      end

      def find_issue
        current_site.issues.find_by_slug!(params[:issue_id])
      end

      def find_process_news
        current_process.news
      end

      def find_page
        pages_scope.find_by_slug!(params[:id])
      end

      def pages_scope
        valid_preview_token? ? current_site.pages.draft : current_site.pages.active
      end
    end
  end
end
