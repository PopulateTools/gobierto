module GobiertoPeople
  class PoliticianCategoryPeopleController < PeopleController
    def index
      super
      @people = @people.politician
    end
  end
end
