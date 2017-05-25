# frozen_string_literal: true

module GobiertoPeople
  class PersonCalendarConfiguration < ApplicationRecord
    belongs_to :person
  end
end
