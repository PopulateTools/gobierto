module GobiertoPeople
  class PersonStatementsController < GobiertoPeople::ApplicationController
    def index
      @statements = current_site.person_statements.active.sorted
    end
  end
end
