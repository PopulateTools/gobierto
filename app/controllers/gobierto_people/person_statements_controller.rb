module GobiertoPeople
  class PersonStatementsController < GobiertoPeople::ApplicationController
    def index
      @people = current_site.people.active
      @statements = current_site.person_statements.active.sorted

      respond_to do |format|
        format.html
        format.json { render json: @statements }
        format.csv  { render csv: GobiertoOpenData::CSVRenderer.new(@statements).to_csv }
      end
    end
  end
end
