module GobiertoPeople
  module People
    class PersonPostsController < BaseController
      def index
        @posts = @person.posts.active.sorted
      end

      def show
        @post = find_post
      end

      private

      def find_post
        @person.posts.active.find(params[:id])
      end
    end
  end
end
