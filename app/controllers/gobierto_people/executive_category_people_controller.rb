module GobiertoPeople
  class ExecutiveCategoryPeopleController < PeopleController
    def index
      super
      @people = @people.executive
    end
  end
end
