module GobiertoPeople
  module People
    class PersonStatementsController < BaseController
      def index
        @statements = find_statements

        if @statements.any?
          redirect_to gobierto_people_person_statement_path(@person, @statements.first)
        end
      end

      def show
        @statement = find_statement
        @other_statements = find_statements - [@statement]
        @statement_content_blocks = @statement.content_blocks(@person.site_id).sorted
      end

      private

      def find_statement
        @person.statements.active.find(params[:id])
      end

      def find_statements
        @person.statements.active.sorted
      end
    end
  end
end
