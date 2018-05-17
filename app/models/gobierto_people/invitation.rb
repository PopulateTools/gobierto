# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Invitation < ApplicationRecord

    belongs_to :person

    validates :person, :organizer, :title, :start_date, :end_date, presence: true

  end
end
