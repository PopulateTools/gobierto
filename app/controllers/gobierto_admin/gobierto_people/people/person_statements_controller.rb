module GobiertoAdmin
  module GobiertoPeople
    module People
      class PersonStatementsController < People::BaseController
        include ::GobiertoCommon::DynamicContentHelper

        def index
          @person_statements = @person.statements.sorted
        end

        def new
          @person_statement_form = PersonStatementForm.new(person_id: @person.id, site_id: current_site.id)
          @person_statement_visibility_levels = get_person_statement_visibility_levels
        end

        def edit
          @person_statement = find_person_statement
          @person_statement_visibility_levels = get_person_statement_visibility_levels

          @person_statement_form = PersonStatementForm.new(
            @person_statement.attributes.except(*ignored_person_statement_attributes).merge(site_id: current_site.id)
          )
        end

        def create
          @person_statement_form = PersonStatementForm.new(person_statement_params.merge(person_id: @person.id, admin_id: current_admin.id, site_id: current_site.id))

          if @person_statement_form.save
            redirect_to(
              edit_admin_people_person_statement_path(@person, @person_statement_form.person_statement),
              notice: t(".success_html", link: gobierto_people_person_statement_url(@person.slug, @person_statement_form.person_statement.slug, host: current_site.domain))
            )
          else
            @person_statement_visibility_levels = get_person_statement_visibility_levels
            render :new
          end
        end

        def update
          @person_statement = find_person_statement
          @person_statement_form = PersonStatementForm.new(person_statement_params.merge(id: params[:id], admin_id: current_admin.id, site_id: current_site.id))

          if @person_statement_form.save
            redirect_to(
              edit_admin_people_person_statement_path(@person, @person_statement),
              notice: t(".success_html", link: gobierto_people_person_statement_url(@person.slug, @person_statement_form.person_statement.slug, host: current_site.domain))
            )
          else
            @person_statement_visibility_levels = get_person_statement_visibility_levels
            render :edit
          end
        end

        private

        def find_person_statement
          @person.statements.find(params[:id])
        end

      def get_person_statement_visibility_levels
        ::GobiertoPeople::PersonStatement.visibility_levels
      end

        def person_statement_params
          params.require(:person_statement).permit(
            :published_on,
            :attachment_file,
            :visibility_level,
            title_translations: [*I18n.available_locales],
            content_block_records_attributes: [
              :id,
              :content_block_id,
              :_destroy,
              :remove_attachment,
              :attachment_file,
              fields_attributes: [:name, :value]
            ]
          )
        end

        def ignored_person_statement_attributes
          %w( created_at updated_at title slug site_id )
        end
      end
    end
  end
end
