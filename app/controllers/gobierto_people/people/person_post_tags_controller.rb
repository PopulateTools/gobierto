# frozen_string_literal: true

module GobiertoPeople
  module People
    class PersonPostTagsController < BaseController
      def show
        @tag = find_tag
        @posts = @person.posts.active.by_tag(@tag).sorted
      end

      private

      def find_tag
        params[:id]
      end
    end
  end
end
