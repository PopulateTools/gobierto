# frozen_string_literal: true

module GobiertoParticipation
  module NewsHelper
    def participation_news_page_container
      if @issue
        @issue.name
      elsif @scope
        @scope.name
      elsif current_process
        current_process.title
      else
        t("gobierto_participation.shared.participation")
      end
    end
  end
end
