module GobiertoPeople
  class PersonPostsController < GobiertoPeople::ApplicationController
    def index
      @people = current_site.people.active
      @posts = current_site.person_posts.active.sorted
    end
  end
end
