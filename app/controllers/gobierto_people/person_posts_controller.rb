module GobiertoPeople
  class PersonPostsController < GobiertoPeople::ApplicationController
    def index
      @people = current_site.people.active
      @posts = current_site.person_posts.active.sorted
      respond_to do |format|
        format.html
        format.rss { render :layout => false }
      end
    end
  end
end
