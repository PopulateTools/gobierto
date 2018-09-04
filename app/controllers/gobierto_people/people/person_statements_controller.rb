# frozen_string_literal: true

module GobiertoPeople
  module People
    class PersonStatementsController < BaseController

      def index
        @statements = find_statements

        if @statements.any?
          args = { person_slug: @person.slug, slug: @statements.first.slug }
          args[:preview_token] = params[:preview_token] if valid_preview_token?
          redirect_to gobierto_people_person_statement_path(args)
        end
      end

      def show
        @statement = find_statement
        @other_statements = find_statements - [@statement]
        @statement_content_blocks = @statement.content_blocks(@person.site_id).sorted
      end

      private

      def find_statement
        person_statements_scope.find_by!(slug: params[:slug])
      end

      def find_statements
        @person.statements.active.sorted
      end

      def person_statements_scope
        valid_preview_token? ? @person.statements : @person.statements.active
      end

    end
  end
end
