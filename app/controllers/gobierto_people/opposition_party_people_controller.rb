module GobiertoPeople
  class OppositionPartyPeopleController < PeopleController
    def index
      @person_party = Person.parties["opposition"]
      super
    end
  end
end
