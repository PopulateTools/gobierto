# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class PersonMessage
    include ActiveModel::Model

    attr_accessor :name, :email, :body, :person

    validates :name, :email, :body, presence: true
    validates :email, format: { with: User::EMAIL_ADDRESS_REGEXP }

    def deliver!
      PersonMailer.new_message({
        person_id: person.id,
        reply_to: email,
        name: name,
        body: body,
      }).deliver_later
    end
  end
end
