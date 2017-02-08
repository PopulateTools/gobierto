module GobiertoAdmin
  module GobiertoPeople
    module People
      class PersonPostsController < People::BaseController
        def index
          @person_posts = @person.posts.sorted
        end

        def new
          @person_post_form = PersonPostForm.new
          @person_post_visibility_levels = get_person_post_visibility_levels
        end

        def edit
          @person_post = find_person_post
          @person_post_visibility_levels = get_person_post_visibility_levels

          @person_post_form = PersonPostForm.new(
            @person_post.attributes.except(*ignored_person_post_attributes)
          )
        end

        def create
          @person_post_form = PersonPostForm.new(
            person_post_params.merge(person_id: @person.id, admin_id: current_admin.id, site_id: current_site.id)
          )

          if @person_post_form.save
            redirect_to(
              edit_admin_people_person_post_path(@person, @person_post_form.person_post),
              notice: t(".success_html", link: gobierto_people_person_post_url(@person, @person_post_form.person_post, domain: current_site.domain))
            )
          else
            @person_post_visibility_levels = get_person_post_visibility_levels
            render :new
          end
        end

        def update
          @person_post = find_person_post
          @person_post_form = PersonPostForm.new(
            person_post_params.merge(id: params[:id], admin_id: current_admin.id, site_id: current_site.id)
          )

          if @person_post_form.save
            redirect_to(
              edit_admin_people_person_post_path(@person, @person_post),
              notice: t(".success_html", link: gobierto_people_person_post_url(@person, @person_post_form.person_post, domain: current_site.domain))
            )
          else
            @person_post_visibility_levels = get_person_post_visibility_levels
            render :edit
          end
        end

        private

        def find_person_post
          @person.posts.find(params[:id])
        end

      def get_person_post_visibility_levels
        ::GobiertoPeople::PersonPost.visibility_levels
      end

        def person_post_params
          params.require(:person_post).permit(
            :title,
            :body,
            :tags,
            :visibility_level
          )
        end

        def ignored_person_post_attributes
          %w(
          created_at updated_at
          )
        end
      end
    end
  end
end
