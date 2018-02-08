module GobiertoPeople
  class PersonStatementsController < GobiertoPeople::ApplicationController

    before_action :check_active_submodules

    def index
      @people = current_site.people.active
      @statements = current_site.person_statements.active.sorted_by_person_position

      respond_to do |format|
        format.html
        format.json { render json: @statements }
        format.csv  { render csv: GobiertoExports::CSVRenderer.new(@statements).to_csv, filename: 'statements' }
      end
    end

    private

    def check_active_submodules
      if !statements_submodule_active?
        redirect_to gobierto_people_root_path
      end
    end

  end
end
