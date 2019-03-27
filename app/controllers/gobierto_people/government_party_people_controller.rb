# frozen_string_literal: true

module GobiertoPeople
  class GovernmentPartyPeopleController < PeopleController
    def index
      @person_party = Person.parties["government"]
      super
    end
  end
end
