module GobiertoPeople
  class PersonPostsController < GobiertoPeople::ApplicationController

    before_action :check_active_submodules

    def index
      @people = CollectionDecorator.new(current_site.people.includes(:historical_charges).active, decorator: PersonDecorator)
      @posts = current_site.person_posts.active.sorted
      respond_to do |format|
        format.html
        format.rss { render layout: false }
      end
    end

    private

    def check_active_submodules
      if !blogs_submodule_active?
        redirect_to gobierto_people_root_path
      end
    end

  end
end
