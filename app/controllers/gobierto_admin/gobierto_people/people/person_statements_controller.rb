# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPeople
    module People
      class PersonStatementsController < People::BaseController

        include ::GobiertoCommon::DynamicContentHelper

        helper_method :gobierto_people_person_statement_preview_url

        def index
          @person_statements = @person.statements.sorted
          @preview_item_url = @person.statements_url(preview: true, admin: current_admin)
        end

        def new
          @person_statement_form = PersonStatementForm.new(person_id: @person.id, site_id: current_site.id)
          @person_statement_visibility_levels = get_person_statement_visibility_levels
        end

        def edit
          load_person_statement
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
              notice: t(".success_html", link: gobierto_people_person_statement_preview_url(@person, @person_statement_form.person_statement, host: current_site.domain))
            )
          else
            @person_statement_visibility_levels = get_person_statement_visibility_levels
            render :new
          end
        end

        def update
          load_person_statement
          @person_statement_form = PersonStatementForm.new(person_statement_params.merge(id: params[:id], admin_id: current_admin.id, site_id: current_site.id))

          if @person_statement_form.save
            redirect_to(
              edit_admin_people_person_statement_path(@person, @person_statement),
              notice: t(".success_html", link: gobierto_people_person_statement_preview_url(@person, @person_statement_form.person_statement, host: current_site.domain))
            )
          else
            @person_statement_visibility_levels = get_person_statement_visibility_levels
            render :edit
          end
        end

        private

        def load_person_statement
          @person_statement = @person.statements.find(params[:id])
          @preview_item = @person_statement
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
          %w(created_at updated_at title slug site_id)
        end

        def gobierto_people_person_statement_preview_url(person, statement, options = {})
          if statement.draft? || statement.person.draft?
            options.merge!(preview_token: current_admin.preview_token)
          end
          gobierto_people_person_statement_url(person.slug, statement.slug, options)
        end

      end
    end
  end
end
