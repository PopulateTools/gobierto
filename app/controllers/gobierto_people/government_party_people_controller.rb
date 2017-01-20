module GobiertoPeople
  class GovernmentPartyPeopleController < PeopleController
    def index
      super
      @people = @people.politician.government
    end
  end
end
