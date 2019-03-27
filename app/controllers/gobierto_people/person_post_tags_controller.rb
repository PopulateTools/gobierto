# frozen_string_literal: true

module GobiertoPeople
  class PersonPostTagsController < GobiertoPeople::ApplicationController
    def show
      @tag = find_tag
      @posts = current_site.person_posts.active.by_tag(@tag).sorted
    end

    private

    def find_tag
      params[:id]
    end
  end
end
