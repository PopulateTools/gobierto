module GobiertoPeople
  class PersonStatementsController < GobiertoPeople::ApplicationController
    def index
      @people = current_site.people.active
      @statements = current_site.person_statements.active.sorted
    end
  end
end
