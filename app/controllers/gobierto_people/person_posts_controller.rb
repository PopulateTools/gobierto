module GobiertoPeople
  class PersonPostsController < GobiertoPeople::ApplicationController
    def index
      @posts = current_site.person_posts.active.sorted
    end
  end
end
