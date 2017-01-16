module GobiertoPeople
  class OppositionPartyPeopleController < PeopleController
    def index
      super
      @people = @people.politician.opposition
    end
  end
end
