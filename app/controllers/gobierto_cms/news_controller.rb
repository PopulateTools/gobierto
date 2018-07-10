# frozen_string_literal: true

module GobiertoCms
  class NewsController < GobiertoCms::PagesController

    private

    def check_collection_type
      render_404 and return false if @collection.item_type != "GobiertoCms::News"
    end
  end
end
